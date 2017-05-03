# -*- coding: utf-8 -*-
#
# This file is part of wormhole-tracker package released under
# the GNU GPLv3 license. See the LICENSE file for more information.

from setuptools import setup, find_packages


setup(
    name='graylog-notifier',
    description="An endpoint for Graylog HTTP notifications",
    version='0.1a0',
    license='GNU GPLv3',
    author='Andrii Murisimov',
    author_email='murisimov@gmail.com',
    classifiers=[
        'Development Status :: 1 - Alpha',
        'Environment :: Server environment',
        'Intended Audience :: Developers',
        'Intended Audience :: System Administrators',
        'Intended Audience :: Webmasters',
        'License :: GNU GPLv3',
        'Operating System :: MacOS :: MacOS X',
        'Operating System :: POSIX',
        'Operating System :: Unix',
        'Programming Languages :: Python',
        'Topic :: Internet :: WWW/HTTP',
    ],
    packages=find_packages(),
    include_package_data=True,
    zip_safe=True,
    install_requires=[
        'setuptools',
        'tornado==4.5.1',
        'futures>=3.0.5',
    ],
    entry_points={
        'console_scripts': [
            'graylog-notifier = graylog_notifier.server:main',
        ]
    },
)
