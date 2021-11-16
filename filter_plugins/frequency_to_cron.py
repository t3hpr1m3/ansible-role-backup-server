#!/usr/bin/python

import re

class FilterModule(object):
    ''' cron frequency filter '''

    def filters(self):
        return {
            'frequency_to_cron': self.frequency_to_cron
        }

    def frequency_to_cron(self, frequency, which):
        if which == 'm' and re.match("^\d+m$", frequency):
            return re.sub('^(\\d+)m', '*/\\1', frequency)
        elif which == 'h' and re.match("^\d+h", frequency):
            return re.sub('^(\\d+)h', '*/\\1', frequency)
        elif which == 'd' and re.match("^\d+d", frequency):
            return re.sub('^(\\d+)d', '*/\\1', frequency)
        else:
            return '*'
