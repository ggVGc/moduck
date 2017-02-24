include(song_macros.m4)
include(_all_parts.m4)

Runner.setPlaying(1);

def(synth, mk(NoteOut, MIDI_OUT_IAC_3, 0, 0::ms, D16, false))
def(kick,
  mk(NoteOut, MIDI_OUT_IAC_2, 0, 0::ms, D4, true)
  .set("note", 0)
)

def(riot, triggerRiot())


Runner.masterClock
  // => mkc(Printer, "master")
  => riot.c
;


riot
  .set("div00", Bar)
  .set("div01", Bar/2)
  // .set("time01", 50) // 50% time delay
;

// riot.set("prob01", 40);



riot.multi([
  mk(Printer, "side0").from("side0")
  ,mk(Printer, "side1").from("side1")
  ,mk(Printer, "bottom0").from("bottom0")
  ,mk(Printer, "bottom1").from("bottom1")
  ,mk(Printer, "bottom2").from("bottom2")
  ,mk(Printer, "bottom3").from("bottom3")
]);



Util.runForever();
