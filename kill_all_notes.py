import time
import rtmidi

portNames = [
  'USB Midi'
  ,'SYSTEM-1m'
  ,'Scarlett 18i8 USB'
  ,'MS-20 mini SYNTH'
  ,'MicroBrute'
  ,'IAC'
]


midiout = rtmidi.MidiOut()
available_ports = midiout.get_ports()

outPorts = []
for portInd, name in enumerate(available_ports):
  for targetName in portNames:
    if targetName in name.strip():
      outPorts.append((name, portInd))
      break



for port in outPorts:
  print("Killing notes for: %s" % (port[0]))
  midiout.open_port(port[1])
  for chan in range(0,16):
    for i in range(0,127):
      midiout.send_message([0x80+chan, i, 0])
      time.sleep(0.0001)
  midiout.close_port()
    # time.sleep(0.5)
# note_on = [0x90, 60, 112] # channel 1, middle C, velocity 112
# note_off = [0x80, 60, 0]
# midiout.send_message(note_on)
# midiout.send_message(note_off)

del midiout


# import sys
# sys.path.append("./portmidizero-0.1")
# import portmidizero as pm
#
# pm.Initialize()
#
# # print "default input device: ",
# # print pm.GetDefaultInputDeviceID()
# # print "default output device: ",
# # print pm.GetDefaultOutputDeviceID()
# # print "num devices: ",
# # print pm.CountDevices()
#
# for deviceID in range(pm.CountDevices()):
#   interf,name,inp,outp,opened = pm.GetDeviceInfo(deviceID)
#   #print deviceID, name, " ",
#
#   isOutput = False
#   if inp == 1: pass #print "(input) ",
#   else:
#     isOutput = True
#     #print "(output) ",
#
#   #if opened == 1: print "(opened)"
#   #else:
#     #print "(unopened)"
#
#   if isOutput:
#     print deviceID, name
#
# MidiOut = pm.Output(18, 1)
# #for chan in range(0,16):
# chan = 0
# #for n in range(1,127):
# MidiOut.Write([[[0x90+chan,1,0],pm.Time()]])
#
#
# # def TestOutput():
# #   latency = int(raw_input("Type latency: "))
# #   print
# #   dev = int(raw_input("Type output number: "))
# #   MidiOut = pm.Output(dev, latency)
# #   print "Midi Output opened with ",latency," latency"
# #   dummy = raw_input("ready to send program 1 change... (type RETURN):")
# #   MidiOut.Write([[[0xc0,0,0],pm.Time()]])
# #   dummy = raw_input("ready to note-on... (type RETURN):")
# #   MidiOut.Write([[[0x90,60,100],pm.Time()]])
# #   dummy = raw_input("read to note-off... (type RETURN):")
# #   MidiOut.Write([[[0x90,60,0],pm.Time()]])
# #   dummy = raw_input("ready to note-on (short form)... (type RETURN):")
# #   MidiOut.WriteShort(0x90,60,100)
# #   dummy = raw_input("ready to note-off (short form)... (type RETURN):")
# #   MidiOut.WriteShort(0x90,60,0)
# #   print
# #   print "chord will arpeggiate if latency > 0"
# #   dummy = raw_input("ready to chord-on/chord-off... (type RETURN):")
# #   chord = [60, 67, 76, 83, 90]
# #   ChordList = []
# #   MidiTime = pm.Time()
# #   for i in range(len(chord)):
# #     ChordList.append([[0x90,chord[i],100], MidiTime + 1000 * i])
# #   MidiOut.Write(ChordList)
# #   while pm.Time() < MidiTime + 1000 + len(chord) * 1000 : pass
# #   ChordList = []
# #   # seems a little odd that they don't update MidiTime here...
# #   for i in range(len(chord)):
# #     ChordList.append([[0x90,chord[i],0], MidiTime + 1000 * i])
# #   MidiOut.Write(ChordList)
# #   print("Sending SysEx messages...")
# #   # sending with timestamp = 0 should be the same as sending with
# #   # timestamp = pm.Time()
# #   dummy = raw_input("ready to send a SysEx string with timestamp = 0 ... (type RETURN):")
# #   MidiOut.WriteSysEx(0,'\xF0\x7D\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\xF7')
# #   dummy = raw_input("ready to send a SysEx list with timestamp = pm.Time() ... (type RETURN):")
# #   MidiOut.WriteSysEx(pm.Time(), [0xF0, 0x7D, 0x10, 0x11, 0x12, 0x13, 0xF7])
# #   dummy = raw_input("ready to close and terminate... (type RETURN):")
# #   del MidiOut
# #
# # def TestInput():
# #   PrintDevices(INPUT)
# #   dev = int(raw_input("Type input number: "))
# #   MidiIn = pm.Input(dev)
# #   print "Midi Input opened. Reading ",NUM_MSGS," Midi messages..."
# # #    MidiIn.SetFilter(pm.FILT_ACTIVE | pm.FILT_CLOCK)
# #   for cntr in range(1,NUM_MSGS+1):
# #     while not MidiIn.Poll(): pass
# #     MidiData = MidiIn.Read(1) # read only 1 message at a time
# #     print "Got message ",cntr,": time ",MidiData[0][1],", ",
# #     print  MidiData[0][0][0]," ",MidiData[0][0][1]," ",MidiData[0][0][2], MidiData[0][0][3]
# #     # NOTE: most Midi messages are 1-3 bytes, but the 4 byte is returned for use with SysEx messages.
# #   del MidiIn
# #
# # num_devices = pm.CountDevices()
# #
# # if num_devices > 0:
# #   TestOutput()
# #
# # pm.Terminate()
# #
