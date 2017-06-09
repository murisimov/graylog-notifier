#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# This file is part of graylog-notifier package released under
# the GNU GPLv3 license. See the LICENSE file for more information.

import logging
from os import sys

from tornado.escape import json_encode
from tornado.gen import coroutine, Return
from tornado.httpclient import AsyncHTTPClient, HTTPError, HTTPRequest
from tornado.httpserver import HTTPServer
from tornado.ioloop import IOLoop
from tornado.options import define, options, parse_command_line, parse_config_file
from tornado.web import Application

from graylog_notifier.routes import routes
from graylog_notifier.settings import settings


define('port', 28282, int)
define('cookie_secret', 'default_secret')
define('slack_url')
define('bot_name')
define('bot_icon')


class App(Application):
    def __init__(self, routes, settings):
        super(App, self).__init__(routes, **settings)
        self.client = AsyncHTTPClient()

    @coroutine
    def notify(self, message, channel=""):
        url = options.slack_url
        bot_name = options.bot_name  #: " + os.uname()[1]
        bot_icon = options.bot_icon
        body = {
            "unfurl_links": True,
            "username": bot_name,
            "icon_url": bot_icon,
            "text": message,
            #"attachments": [
            #    { "title": subject },
            #]
        }
        body = json_encode(body)
        request = HTTPRequest(url, method="POST", body=body)
        try:
            response = yield self.client.fetch(request)
        except HTTPError as e:
            logging.error(e)
            raise Return("ERROR OCCURRED: " + str(e))
        else:
            raise Return("Notification sent")


def main():
    try:
        parse_config_file('/home/graylog-notifier/graylog-notifier.conf')
    except Exception as e:
        logging.warning(e)
        parse_command_line()

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
