include(song_macros.m4)
include(macros.m4)




def(launchpad, mk(MidInp, MIDI_IN_LAUNCHPAD, 0))
def(oxygen, mk(MidInp, MIDI_IN_OXYGEN, 0));


/* recbu => frm("hasData").to(mk(Printer, "hasData")).c; */


launchpad => mk(Printer, "did").from("cc104").c;

fun ModuckP recBufUI(ModuckP recBuf){
  def(in, mk(Repeater, [
    P_Trigger
    ,"clearAllSwitch"
  ]));
  def(out, mk(Repeater));

  in => mk(Printer, "clearAllSwitch").from("clearAllSwitch").c;

  /* 
   (in=>frm(P_Trigger).c)
     .b(recBuf.to(P_ClearAll).when(in,"clearAllSwitch"))
     .b(recBuf.to("toggleRec").whenNot(in,"clearAllSwitch"))
   ;
   */

  in
    => frm(P_Trigger).c
    => iff(in,"clearAllSwitch")
      .then(recBuf.to(P_ClearAll))
      .els(recBuf.to("toggleRec")).c
  ;


  return mk(Wrapper, in, out);
}


MidiOut circuitDeviceOut;
<<<"Opening circuit out">>>;
circuitDeviceOut.open(MIDI_OUT_CIRCUIT);
def(circuit, mk(NoteOut, circuitDeviceOut, 0, false));


ModuckP bufs[0];
ModuckP uis[0];

for(0=>int i;i<4;++i){
  def(buf, mk(RecBuf, Bar));
  def(ui, recBufUI(buf));
  uis << ui;
  bufs << buf;
  launchpad => frm("note0").to(ui, "clearAllSwitch").c;
  launchpad => frm("note"+(16+i)).to(ui, P_Trigger).c;
  Runner.masterClock => buf.to(P_Clock).c;
  oxygen => frm("note").to(buf, P_Set).c;
  buf => circuit.c;
}

/// INDICATORS

MidiOut launchpadDeviceOut;
launchpadDeviceOut.open(MIDI_OUT_LAUNCHPAD);

/* 
 recbu
   => frm("hasData").c
   => mk(TrigValue, 0).c
   => mk(NoteOut, launchpadDeviceOut, 0, false).c
 ;
 
 
 
 recbu
   => frm("recording").c
   => mk(TrigValue, 16).c
   => mk(NoteOut, launchpadDeviceOut, 0, false).c
 ;
 */




Runner.setPlaying(1);
Util.runForever();
