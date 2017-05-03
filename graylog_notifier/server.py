#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# This file is part of graylog-notifier package released under
# the GNU GPLv3 license. See the LICENSE file for more information.

import logging
from os import sys

from tornado.httpserver import HTTPServer
from tornado.ioloop import IOLoop
from tornado.options import  define, options, parse_command_line
from tornado.web import Application

from graylog_notifier.routes import routes
from graylog_notifier.settings import settings


define('port', 28282, int)
define('cookie_secret', 'default_secret')


class App(Application):
    def __init__(self, routes, settings):
        super(App, self).__init__(routes, **settings)


def main():
    try:
        parse_command_line()
    except Exception as e:
        logging.error(e)
        sys.exit(1)

    settings['cookie_secret'] = options.cookie_secret
    app = App(routes, settings)
    http_server = HTTPServer(app)
    http_server.listen(options.port)

    try:
        logging.info("Starting server...")
        IOLoop.current().start()
    except (SystemExit, KeyboardInterrupt):
        logging.info("Stopping server.")
        IOLoop.current().stop()
        sys.exit()

    except Exception as e:
        logging.error(e)
        IOLoop.current().stop()
        sys.exit(1)

if __name__ == '__main__':
    main()
