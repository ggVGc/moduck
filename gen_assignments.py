#!/usr/bin/python 

import sys

spl = sys.argv[1].split(";")

vals = [x.strip().split(" ") for x in spl]

for v in vals:
  name = v[-1]
  if name!= '':
    varType = v[0]
    op = "@=>"
    if varType == "string" or varType == "int" and not "[" in name:
      op = "=>"
    name = name.replace("[", "").replace("]", "")
    print("%s %s ret.%s;" % (name, op, name))

