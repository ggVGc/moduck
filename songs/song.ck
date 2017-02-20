


138 => BPM;
def(kick,
  mk(NoteOut, MIDI_OUT_IAC_2, 0, 0::ms, D4, true)
  .set("note", 0)
)

(masterClock
  => mk(PulseDiv, Bar, 1).map(P_Trigger, P_Reset).propagate(P_Trigger).c)
  // .b(mk(Printer, "Reset received").from(P_Reset))
  .b(mk(Printer, "Tick received").from(P_Trigger))
  .b(mk(Printer, "Reset received").from(P_Reset))
;


1 => PLAY;
