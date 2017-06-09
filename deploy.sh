#!/bin/sh
#
# This file is part of graylog-notifier package released under
# the GNU GPLv3 license. See the LICENSE file for more information.

# This script does the following:
# - Checks if it's running from the correct dir
# - Checks if there is a valid python version available
# - Removes old daemon file if it exists
# - Adds user which will run the daemon
# - Installs virtualenv python package
# - Sets up the venv for the application
# - Installs application itself
# - Copies configuration template
# - Installs application daemon
# - Starts application daemon.


APP_NAME="graylog-notifier"

PACKAGE_DIR="graylog_notifier"

ENVS_DIR="/home/${APP_NAME}/.envs"

APP_ENV="${ENVS_DIR}/${APP_NAME}"

DAEMON_PATH="/home/${APP_NAME}/${APP_NAME}-daemon"

PY_VERSION="2.7"

CONF_FILE="${APP_NAME}.conf"

VENV="virtualenv"

print () {
    echo; echo $1; echo
}


# Check if script is running from the correct place
if [ -z "$(ls . | grep 'deploy.sh')" -o -z "$(ls . | grep 'setup.py')" ]; then
    print 'Please launch deploy script right from application root directory'
    exit 1
fi

# Check if correct python version is installed
if [ -z "$(which python${PY_VERSION} 2>/dev/null | grep -E "(/\w+)+/python${PY_VERSION}")" ]; then
    print "Seems like python${PY_VERSION} is not installed. Please install python${PY_VERSION} first."
    exit 1
fi

# Stop daemon if it is running, just in case
${DAEMON_PATH} stop &> /dev/null
rm -f ${DAEMON_PATH} &> /dev/null

print "Adding user '${APP_NAME}'..."
if id -u ${APP_NAME} > /dev/null; then
    print "User '${APP_NAME}' already exists, skipping."
else
    if useradd ${APP_NAME} -m -b /home -s /bin/bash -U; then
        print "User '${APP_NAME}' have been created."
    else
        print "Failed to create user '${APP_NAME}', aborting."
        exit 1
    fi
fi

print "Installing virtualenv..."
if pip install virtualenv; then
    # Create vitrualenv for the app
    mkdir -p ${ENVS_DIR}

    if [ -d "${APP_ENV}" ]; then
        print "Cleaning old virtualenv..."
        rm -rf ${APP_ENV}
    fi

    print "Success. Creating virtualenv for ${APP_NAME}..."
    if python${PY_VERSION} -m ${VENV} ${APP_ENV}; then

        # Upgrade pip
        ${APP_ENV}/bin/pip install --upgrade pip &>/dev/null


        print "Success. Installing ${APP_NAME} application..."
        # Install application and its dependencies under virtualenv
        if ${APP_ENV}/bin/python setup.py install --record files.txt >install.log; then
            print "Application installed."
        else
            print "Failed to install application, aborting."
            exit 1
        fi
    else
        print "Failed to create virtualenv, aborting."
        exit 1
    fi
else
    print "Failed to install virtualenv, aborting."
    exit 1
fi

if [ -n "${CONF_FILE}" ]; then
    print "Copying configuration file template..."
    if ! [ -f "/home/${APP_NAME}/${CONF_FILE}" ]; then
        if cp ${CONF_FILE} /home/${APP_NAME}/${CONF_FILE}; then
            print "Configuration template copied."
        else
            print "Failed to copy configuration template"
        fi
    else
        print "Configuration file already exists, skipping."
    fi
fi

print "Installing ${APP_NAME} daemon..."
if cp ${PACKAGE_DIR}/daemon/${APP_NAME}-daemon ${DAEMON_PATH} && chmod +x ${DAEMON_PATH}; then
    print "Daemon script installed."
else
    print "Failed to copy daemon script to the ${DAEMON_PATH}"
    exit 1
fi

print "Setting up access rights..."
if chown -R ${APP_NAME}:${APP_NAME} /home/${APP_NAME}; then
    print "Rights given."
else
    print "Error occured, aborting."
    exit 1
fi
