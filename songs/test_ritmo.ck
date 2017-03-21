include(song_macros.m4)
include(_all_parts.m4)
include(_all_instruments.m4)


def(rit, ritmo([fourFour(B, 0), fourFour(B2, 0)]));

Runner.masterClock
  => rit.c
  => mk(Printer, "tick").c
;

Runner.setPlaying(1);

Util.runForever();

