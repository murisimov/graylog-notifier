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


app_name="graylog-notifier"

package_dir="graylog_notifier"

envs_dir="/home/${app_name}/.envs"

app_env="${envs_dir}/${app_name}"

daemon_path="/home/${app_name}/${app_name}-daemon"

py_version="2.7"

venv="virtualenv"

print () {
    echo; echo $1; echo
}


# Check if script is running from the correct place
if [ -z "$(ls . | grep 'deploy.sh')" -o -z "$(ls . | grep 'setup.py')" ]; then
    print 'Please launch deploy script right from application root directory'
    exit 1
fi

# Check if correct python version is installed
if [ -z "$(which python${py_version} 2>/dev/null | grep -E "(/\w+)+/python${py_version}")" ]; then
    print "Seems like python${py_version} is not installed. Please install python${py_version} first."
    exit 1
fi

# Stop daemon if it is running, just in case
${daemon_path} stop &> /dev/null
rm -f ${daemon_path} &> /dev/null

print "Adding user '${app_name}'..."
if id -u ${app_name} > /dev/null; then
    print "User '${app_name}' already exists, skipping."
else
    if useradd ${app_name} -m -b /home -s /bin/bash -U; then
        print "User '${app_name}' have been created."
    else
        print "Failed to create user '${app_name}', aborting."
        exit 1
    fi
fi

print "Installing virtualenv..."
if pip install virtualenv; then
    # Create vitrualenv for the app
    mkdir -p ${envs_dir}

    if [ -d "${app_env}" ]; then
        print "Cleaning old virtualenv..."
        rm -rf ${app_env}
    fi

    print "Success. Creating virtualenv for ${app_name}..."
    if python${py_version} -m ${venv} ${app_env}; then
        print "Success. Installing ${app_name} application..."
        # Install application and its dependencies under virtualenv
        if ${app_env}/bin/python setup.py install --record files.txt >install.log; then
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

if [ -n "${conf_file}" ]; then
    print "Copying configuration file template..."
    if ! [ -f "/home/${app_name}/${conf_file}" ]; then
        if cp ${conf_file} /home/${app_name}/${conf_file}; then
            print "Configuration template copied."
        else
            print "Failed to copy configuration template"
        fi
    else
        print "Configuration file already exists, skipping."
    fi
fi

print "Installing ${app_name} daemon..."
if cp ${package_dir}/daemon/${app_name}-daemon ${daemon_path} && chmod +x ${daemon_path}; then
    print "Daemon script installed."
else
    print "Failed to copy daemon script to the ${daemon_path}"
    exit 1
fi

print "Setting up access rights..."
if chown -R ${app_name}:${app_name} /home/${app_name}; then
    print "Rights given."
else
    print "Error occured, aborting."
    exit 1
fi