# -*- coding: utf-8 -*-
#
# This file is part of graylog-notifier package released under
# the GNU GPLv3 license. See the LICENSE file for more information.

import logging

from tornado.escape import json_decode
from tornado.gen import coroutine, Return, sleep
from tornado.web import RequestHandler


class NotificationHandler(RequestHandler):
    @coroutine
    def post(self):
        logging.info(json_decode(self.request.body))
