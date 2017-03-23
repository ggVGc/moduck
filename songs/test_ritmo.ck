include(song_macros.m4)
include(_all_parts.m4)
include(_all_instruments.m4)

def(rit, ritmo([
  fourFour(B, 0)
  ,fourFour(B2, 0)
  ,fourFour(B4, 0)
  ,fourFour(B8, 0)
  ,fourFour(B16, 0)
  ,fourFour(B32, 0)

  ,fourFour(B7, 0)
  ,fourFour(B5, 0)
  ,fourFour(B3, 0)
]));
def(val, mk(Value, 3))
def(inp, mk(MidInp, MIDI_IN_LAUNCHPAD, 0))

def(out, mk(NoteOut, MIDI_OUT_ZYNADDSUBFX, 0, 0::ms, 100::ms, true))

/* 
 inp
   .b(mk(Printer, "cc").from("cc"))
   .b(mk(Printer, "note").from("note"))
   .b(mk(Printer, "vel").from("velocity"))
   .b(mk(Printer, "ccVal").from("ccValue"))
 ;
 */

/* def(block, mk(Blocker)) */

/* 
 inp => block.fromTo("cc", P_Gate).c;
 inp => val.fromTo("note", "value").c;
 */

for(0=>int i;i<6;++i){
  inp => rit.fromTo("note"+i, ""+i).c;
}

for(16=>int i;i<19;++i){
  inp => rit.fromTo("note"+i, ""+(i-16+6)).c;
}

Runner.masterClock
  => rit.listen(P_Clock).c
  => mk(Printer, "tick").c
  => mk(Value, 50).c
  => mk(Printer, "out").c
  => out.c
;
Runner.setPlaying(1);

Util.runForever();

