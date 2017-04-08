include(song_macros.m4)
include(macros.m4)
include(constants.m4)

def(launchpad, mk(MidInp, MIDI_IN_LAUNCHPAD, 0))
def(oxygen, mk(MidInp, MIDI_IN_OXYGEN, 0));

fun ModuckP recBufUI(ModuckP recBuf){
  def(in, mk(Repeater, [
    P_Trigger
    ,P_ClearAll
  ]));
  def(out, mk(Repeater));

  in
    => frm(P_Trigger).c
    => iff(in, P_ClearAll)
      .then(recBuf.to(P_ClearAll))
      .els(recBuf.to("toggleRec")).c
  ;

  return mk(Wrapper, in, out);
}


MidiOut circuitDeviceOut;
<<<"Opening circuit out">>>;
circuitDeviceOut.open(MIDI_OUT_CIRCUIT);
def(circuit, mk(NoteOut, circuitDeviceOut, 0));

MidiOut launchpadDeviceOut;
launchpadDeviceOut.open(MIDI_OUT_LAUNCHPAD);

def(lpOut, mk(NoteOut, launchpadDeviceOut, 0));

ModuckP bufs[0];
ModuckP uis[0];

fun ModuckP red(){
  return mk(TrigValue, 70);
}

fun ModuckP green(){
  return mk(TrigValue, 100);
}

fun ModuckP yellow(){
  return mk(TrigValue, 127);
}


for(0=>int i;i<4;++i){
  def(buf, mk(RecBuf, Bar));
  def(ui, recBufUI(buf));
  uis << ui;
  bufs << buf;
  launchpad => frm("note0").to(ui, P_ClearAll).c;
  launchpad => frm("note"+(16+i)).to(ui, P_Trigger).c;
  Runner.masterClock => buf.to(P_Clock).c;
  oxygen => frm("note").to(buf, P_Set).c;
  buf => circuit.to("note").c;

  def(prio, mk(Prio));
  prio => lpOut.to("note"+(16+i)).c;

  buf
    .b("hasData", green() => prio.to(0).c)
    .b(P_Recording, red() => prio.to(1).c)
  ;
}

Runner.setPlaying(1);
Util.runForever();
