include(song_macros.m4)
include(macros.m4)
include(constants.m4)

Runner.setPlaying(1);

def(launchpad, mk(MidInp, MIDI_IN_LAUNCHPAD, 0));
def(oxygen, mk(MidInp, MIDI_IN_OXYGEN, 0));

fun ModuckP recBufUI(ModuckP recBuf){
  def(in, mk(Repeater, [
    P_Trigger
    ,P_ClearAll
    ,P_Rec
  ]));
  def(out, mk(Repeater));

  in
    => frm(P_Trigger).c
      => iff(in, P_ClearAll).then(
          recBuf.to(P_ClearAll))
      .els(iff(in, P_Rec).then(
        recBuf.to(toggl(P_Rec)))
      .els(
        recBuf.to(toggl(P_Play))
      )).c;

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

fun ModuckP red2(){
  return mk(TrigValue, 79);
}

fun ModuckP green(){
  return mk(TrigValue, 80);
}

fun ModuckP green2(){
  return mk(TrigValue, 108);
}


fun ModuckP orange(){
  return mk(TrigValue, 47);
}

fun ModuckP yellow(){
  return mk(TrigValue, 127);
}


for(0=>int i;i<8;++i){
  def(buf, mk(RecBuf, Bar));
  def(ui, recBufUI(buf));
  uis << ui;
  bufs << buf;

  Runner.masterClock => buf.to(P_Clock).c;

  launchpad
    .b(frm("cc104").to(mk(Bigger, 0) => ui.to(P_ClearAll).c))
    .b(frm("cc105").to(mk(Bigger, 0) => ui.to(P_Rec).c))
    .b(frm("note"+i).to(ui, P_Trigger));

  oxygen => frm("note").to(buf, P_Set).c;

  buf => circuit.to("note").c;

  // Indicators
  def(trigOut, mk(Prio) => lpOut.to("note"+i).c);
  def(trigCol, iff(buf, P_Recording).then(red2()).els(yellow()));
  buf
    .b("hasData", green() => trigOut.to(0).c)
    .b(P_Playing, orange() => trigOut.to(1).c)
    .b(P_Recording, red() => trigOut.to(2).c)
    .b(P_Trigger, trigCol => trigOut.to(3).c)
  ;
}

oxygen => frm("note").c
=> mk(Printer, "X").c
=> lpOut.to("note16").c;

Util.runForever();
