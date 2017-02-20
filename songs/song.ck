


138 => BPM;
def(kick,
  mk(NoteOut, MIDI_OUT_IAC_2, 0, 0::ms, D4, true)
  .set("note", 0)
)

masterClock
  => mk(PulseDiv, B*2, 1).map(P_Trigger, P_Reset).c
  => mk(Printer, "Reset received").from(P_Reset).c
  // => P(Patch.thru(mk(Repeater) => mk(Printer, "tick").from(P_Trigger).c)).c
;


1 => PLAY;
