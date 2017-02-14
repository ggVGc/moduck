import os
import subprocess


def findDevicePorts(hintName, fullString):

  inputsStart = fullString.find("MIDI inputs")
  outputsStart = fullString.find("MIDI outputs")

  def findPort(searchStr):
    ind = searchStr.lower().find(hintName.lower())
    if ind == -1:
      return -1
    i1 = searchStr.rfind("[", 0, ind)
    i2 = searchStr.find("]", i1)
    return searchStr[i1+1:i2]
  return findPort(fullString[inputsStart:outputsStart]), findPort(fullString[outputsStart:])





proc = subprocess.Popen(["chuck", "--probe"], stderr=subprocess.PIPE, stdout=subprocess.PIPE)
chuckOutput = " ".join(proc.stderr.readlines())
proc.wait()
#print chuckOutput

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
  ,["system-1"]
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
]


import sys

with open(sys.argv[1], "w") as outFile:
  for d in deviceHints:
    portIn, portOut = findDevicePorts(d[0], chuckOutput)
    name = d[0]
    if len(d) > 1:
      name = d[1]
    def w(inOut,p):
      outFile.write("define(MIDI_%s_%s, %s)\n" % 
          (inOut.upper(), name.upper().replace(" ","_").replace("-", "_"), p))
    if portIn != -1:
      w("in", portIn)
    else:
      w("in", 16)
    if portOut != -1:
      w("out", portOut)
    else:
      w("out", 16)


  
  #for p in ports:


