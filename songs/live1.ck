
include(song_macros.m4)
include(_all_parts.m4)
include(_all_instruments.m4)


fun ModuckP pulseRitmo(ModuckP input){
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
  ]));

  for(0=>int i;i<7;++i){
    input => rit.fromTo("note"+i, ""+i).c;
  }

  for(16=>int i;i<21;++i){
    input => rit.fromTo("note"+i, ""+(i-16+7)).c;
  }

  return rit;
}


def(out, mk(NoteOut, MIDI_OUT_ZYNADDSUBFX, 0, 0::ms, 100::ms, true))
def(launchpad, mk(MidInp, MIDI_IN_LAUNCHPAD, 0))

Runner.masterClock
  => pulseRitmo(launchpad).listen(P_Clock).c
  /* => mk(Printer, "tick").c */
  => mk(Value, 50).c
  => mk(SampleHold, 100::ms).to(P_Set).listen(P_Trigger).c
  /* => mk(Printer, "out").c */
  => out.c
;
Runner.setPlaying(1);

Util.runForever();

