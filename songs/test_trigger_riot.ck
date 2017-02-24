include(song_macros.m4)
include(_all_parts.m4)

Runner.setPlaying(1);

def(synth, mk(NoteOut, MIDI_OUT_IAC_1, 0, 0::ms, D4, false))
def(kick,

  mk(NoteOut, MIDI_OUT_IAC_2, 0, 0::ms, D4, true)
  .set("note", 0)
)

def(snare, mk(NoteOut, MIDI_OUT_IAC_2, 0, 0::ms, D4, true)
  .set("note", 1)
)
def(hat, mk(NoteOut, MIDI_OUT_IAC_2, 0, 0::ms, D4, true)
  .set("note", 2)
)

def(riot, triggerRiot(4, B4))


Runner.masterClock
  => riot.c
;


riot
  .set("div00", 4)
  .set("div10", 9)
  .set("div13", 5)
  .set("div12", 14)
  .set("div01", 16)
  .set("div02", 3)
  .set("div32", 7)
  .set("div33", 11)
  .set("delay01", 4)
  // .set("div10", 8)
  // .set("time01", 1) // 50% time delay
;

// riot.set("prob01", 40);



riot.multi([
  (mk(Value, 100) => kick.c).from("side0")
  ,(mk(Value, 100) => snare.c).from("side1")
  ,(mk(Value, 100) => hat.c).from("side2")
  ,(mk(Sequencer, [50,47,53,55,48,58]) => synth.c).from("bottom1")
  // ,mk(Printer, "side1").from("side1")
  // mk(Printer, "bottom0").from("bottom0")
  // ,mk(Printer, "bottom1").from("bottom1")
  // ,mk(Printer, "bottom2").from("bottom2")
  // ,mk(Printer, "bottom3").from("bottom3")
]);


Util.runForever();
