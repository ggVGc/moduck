include(song_macros.m4)

def(seq,
  mk(Sequencer, [1,2,3,4])
  .set("length", 8)
);


def(keys, mk(MidInp, MIDI_IN_OXYGEN, 0));
def(out, mk(NoteOut, MIDI_OUT_CIRCUIT, 0, false));

keys => out.from("note").c;

seq
  => seq.fromTo("curStep", "targetStep").c
;

keys
  => mk(Printer, "").from("note").c
  => seq.to(P_Set).c
;


seq
  => mk(Printer, "target").from("targetStep").c;

Runner.masterClock
  => mk(PulseDiv, B).c
  => seq.c
  => out.c
  => mk(Printer, "").c
;


Runner.setPlaying(1);

Util.runForever();

