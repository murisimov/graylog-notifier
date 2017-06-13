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
        alert = json_decode(self.request.body)['check_result']
        subject = "*%s*\n%s\n\n" % (
            alert['triggered_condition']['title'],
            alert['result_description']
        )
        base = [
            "`" + m['fields']['tag'] + '` : ' +
            m['fields'].get('file', '') +
            "\n> ```%s```" % m['message']
            for m in alert['matching_messages']
        ]
        base = '\n'.join(base)
        message = subject + base
        result = yield self.application.notify(message)
