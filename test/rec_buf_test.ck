include(song_macros.m4)
include(macros.m4)
include(constants.m4)
include(parts/rec_buf_ui.ck)

Runner.setPlaying(1);

def(launchpad, mk(MidInp, MIDI_IN_LAUNCHPAD, 0));
def(oxygen, mk(MidInp, MIDI_IN_OXYGEN, 0));

MidiOut circuitDeviceOut;
<<<"Opening circuit out">>>;
circuitDeviceOut.open(MIDI_OUT_CIRCUIT);
def(circuit, mk(NoteOut, circuitDeviceOut, 0));

MidiOut launchpadDeviceOut;
launchpadDeviceOut.open(MIDI_OUT_LAUNCHPAD);

def(lpOut, mk(NoteOut, launchpadDeviceOut, 0));


for(0=>int i;i<8;++i){
  def(buf, mk(RecBuf, Bar));
  def(ui, recBufUI(buf));

  Runner.masterClock => buf.to(P_Clock).c;

  launchpad
    .b(frm("cc104").to(mk(Bigger, 0) => ui.to(P_ClearAll).c))
    .b(frm("note"+i).to(ui, P_Trigger));

  ui => lpOut.to("note"+i).c;

  oxygen => frm("note").to(buf, P_Set).c;

  buf => circuit.to("note").c;

}

oxygen => frm("note").c
=> mk(Printer, "X").c
=> lpOut.to("note16").c;

Util.runForever();
