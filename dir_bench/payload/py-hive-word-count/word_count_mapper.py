#!/usr/bin/python
import sys

for line in sys.stdin:
	line = line.strip();
	words = line.split(" ");
	# write the tuples to stdout
	for word in words:
		print '%s\t%s' % (word, "1")