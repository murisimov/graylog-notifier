# -*- coding: utf-8 -*-
#
# This file is part of graylog-notifier package released under
# the GNU GPLv3 license. See the LICENSE file for more information.

import graylog_notifier.handlers.main as main


routes = [
    (r"/graylog-notifications", main.NotificationHandler),
]
