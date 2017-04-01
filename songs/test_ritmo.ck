include(song_macros.m4)
/* include(_all_parts.m4) */
/* include(_all_instruments.m4) */
include(instruments/ritmo.ck)
include(parts/rhythms.ck)

def(rit, ritmo(true, [
  fourFour(B*2, 0)
  ,fourFour(B, 0)
  ,fourFour(B2, 0)
  ,fourFour(B4, 0)
  ,fourFour(B8, 0)
  ,fourFour(B16, 0)
  ,fourFour(B32, 0)

  ,fourFour(B+B2, 0)
  ,fourFour(B2+B4, 0)
  ,fourFour(B4+B8, 0)
  ,fourFour(B8+B16, 0)
  ,fourFour(B16+B32, 0)
  /* ,fourFour(B7, 0) */
  /* ,fourFour(B5, 0) */
  /* ,fourFour(B3, 0) */
]));
def(val, mk(Value, 3))
def(inp, mk(MidInp, MIDI_IN_LAUNCHPAD, 0))

def(out, mk(NoteOut, MIDI_OUT_CIRCUIT, 0, true));

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

for(0=>int i;i<7;++i){
  inp => rit.fromTo("note"+i, ""+i).c;
}

for(16=>int i;i<21;++i){
  inp => rit.fromTo("note"+i, ""+(i-16+7)).c;
}

Runner.masterClock
  => rit.listen(P_Clock).c
  => mk(Printer, "tick").c
  => mk(Value, 50).c
  => mk(SampleHold, 100::ms).fromTo(P_Default, P_Set).listen(P_Trigger).c
  => mk(Printer, "out").c
  => out.c
;
Runner.setPlaying(1);

Util.runForever();

