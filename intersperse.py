#!/usr/bin/python 

import sys

def _intersperse(iterable, delimiter):
    it = iter(iterable)
    yield next(it)
    for x in it:
        yield delimiter
        yield x

def intersperse(iterable, delimiter):
  return [x for x in _intersperse(iterable, delimiter)][:-2]


termSep = ";"


for x in intersperse(sys.argv[2].split(termSep), sys.argv[1]):
  sys.stdout.write(x+"\n")
