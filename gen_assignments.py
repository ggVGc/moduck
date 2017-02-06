#!/usr/bin/python 

import sys

spl = sys.argv[1].split(";")

vals = [x.strip().split(" ")[-1] for x in spl]

for v in vals:
  if v != '':
    print("%s => ret.%s;" % (v, v))

