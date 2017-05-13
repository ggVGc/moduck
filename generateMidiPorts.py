deviceHints = [
  ["through"]
  ,["launchpad"]
  ,["yoke:  1", "yoke 1"]
  ,["yoke:  2", "yoke 2"]
  ,["yoke:  3", "yoke 3"]
  ,["yoke:  4", "yoke 4"]
  ,["yoke:  5", "yoke 5"]
  ,["yoke:  6", "yoke 6"]
  ,["yoke:  7", "yoke 7"]
  ,["yoke:  8", "yoke 8"]
  ,["yoke:  9", "yoke 9"]
  ,["ms-20"]
  ,["SYSTEM-1m", "sys1"]
  ,["jack"]
  ,["zynaddsubfx"]
  ,["microbrute"]
  ,["usb midi"]
  ,["IAC Driver", "IAC_1"]
  ,["IAC Driver IAC Bus 2", "IAC_2"]
  ,["IAC Driver IAC Bus 3", "IAC_3"]
  ,["IAC Driver IAC Bus 4", "IAC_4"]
  ,["IAC Driver IAC Bus 5", "IAC_5"]
  ,["IAC Driver IAC Bus 6", "IAC_6"]
  ,["nanoKONTROL", "NANO_KTRL"]
  ,["circuit", "circuit"]
  ,["oxygen", "oxygen"]
  ,["K49", "K49"]
  ,["BCR2000", "bcr"]
  ,["APC MINI", "apc"]
]

import os
import subprocess


def findDevicePorts(hintName, fullString, minCount):
  inputsStart = fullString.find("MIDI inputs")
  outputsStart = fullString.find("MIDI outputs")

  def findPort(searchStr):
    ind = searchStr.lower().find(hintName.lower())
    if ind == -1:
      return (-1,-1)
    i1 = searchStr.rfind("[", 0, ind)
    i2 = searchStr.find("]", i1)
    return (ind+1, searchStr[i1+1:i2])

  curInStart = inputsStart
  curOutStart = outputsStart

  x = 0
  while True:
    (inAdd, inPort) = findPort(fullString[curInStart:outputsStart])
    curInStart += inAdd
    (outAdd, outPort) = findPort(fullString[curOutStart:])
    curOutStart += outAdd
    if x>=minCount:
      if type(outPort) is str or type(inPort) is str or (inPort == -1 and outPort == -1):
        break
    x+=1
    yield (inPort, outPort)



def write(name, inOut, p):
  outFile.write("define(MIDI_%s_%s, %s)\n" % 
      (inOut.upper(), name.upper().replace(" ","_").replace("-", "_"), p))

proc = subprocess.Popen(["chuck", "--probe"], stderr=subprocess.PIPE, stdout=subprocess.PIPE)
chuckOutput = " ".join(proc.stderr.readlines())
proc.wait()

import sys

with open(sys.argv[1], "w") as outFile:
  for d in deviceHints:
    rootName = d[0]
    if len(d) > 1:
      rootName = d[1]

    ports = [x for x in findDevicePorts(d[0], chuckOutput, 2)]
    if len(ports) == 0:
        write(rootName, "in", 32)
        write(rootName, "out", 32)
    else:
      for (ind, (portIn, portOut)) in enumerate(ports):
        name = rootName+(ind > 0 and str(ind) or "")
        write(name, "in", portIn==-1 and 32 or portIn)
        write(name, "out", portOut==-1 and 32 or portOut)


    # if portIn != -1:
    #   w("in", portIn)
    # else:
    #   w("in", 32)
    # if portOut != -1:
    #   w("out", portOut)
    # else:
    #   w("out", 32)
    #
