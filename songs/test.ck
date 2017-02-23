include(song_macros.m4)
include(_all_parts.m4)

Runner.setPlaying(true);

def(synth, mk(NoteOut, MIDI_OUT_IAC_3, 0, 0::ms, D16, false))
def(kick,
  mk(NoteOut, MIDI_OUT_IAC_2, 0, 0::ms, D4, true)
  .set("note", 0)
)


Runner.masterClock
  => mk(PulseDiv, B).c
  => mk(Probably, 90).c
  => mk(Printer, "").c
;



Util.runForever();
