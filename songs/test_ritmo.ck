include(song_macros.m4)
include(_all_parts.m4)
include(_all_instruments.m4)

def(rit, ritmo([fourFour(B, 0), fourFour(B2, 0)]));


def(val, mk(Value, 3))

def(inp, mk(MidInp, MIDI_IN_LAUNCHPAD, 0))


inp
  .b(mk(Printer, "cc").from("cc"))
  .b(mk(Printer, "note").from("note"))
  .b(mk(Printer, "vel").from("velocity"))
  .b(mk(Printer, "ccVal").from("ccValue"))
;

/* 
 Runner.masterClock
   => val.c
   => mk(Printer, "tick").c
 ;
 */
Runner.setPlaying(1);

Util.runForever();

