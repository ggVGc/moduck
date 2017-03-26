include(song_macros.m4)

def(seq,
  mk(Sequencer, [1,2,3,4])
  .set("length", 8)
);



Runner.masterClock
  => mk(PulseDiv, B).c
  => seq.c
  => mk(Printer, "").c
;


Runner.setPlaying(1);

Util.runForever();

