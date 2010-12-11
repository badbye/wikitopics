#!/usr/bin/env python
#
# pick_recent_date.py
#
# Extract date values from a APF file and check its variable formats.
# also needs the corresponding SGM file so it extracts the original string.
#
# pick_recent_date.py [date] [sgm] [apf]

# For the given SERIF files, print the temporal expression that is closest to the given date.
# Called by the batch_pick_recent_dates.sh script.

# Usage: pick_recent_date.py [date] [sgm] [apf]

# [date]
# 	the date

# [sgm]
# 	the .sgm file

# [apf]
# 	the .apf file

import sys
import re
import bisect
from xml.dom.minidom import parse
import serif
import datetime



if __name__=='__main__':
	if len(sys.argv) != 4:
		print "Usage: pick_recent_date.py [date] [sgm] [apf]"
		sys.exit(1)
	date = serif.convert_to_date(sys.argv[1])
	text = serif.read_sgm(sys.argv[2])
	data = serif.read_apf(text, sys.argv[3])
	btimex = serif.find_best_timex(date, text, data)
	if btimex:
		start, end = text.expand(btimex.start, btimex.end)
		line = serif.resolveCoref(text, data, start, end)
		print line.encode('utf-8')

