
include(song_macros.m4)
include(_all_parts.m4)
include(_all_instruments.m4)


fun ModuckP makePulseRitmo(){
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
  return rit;
}

fun ModuckP makeNoteRitmo(){
  def(rit, ritmo(true, [
    mk(Sequencer, [0,1,2])
    ,mk(Sequencer, [3,4,5])
  ]));


  return rit;
}

def(out, mk(NoteOut, MIDI_OUT_ZYNADDSUBFX, 0, 0::ms, 100::ms, true))

def(pulseRitmo, makePulseRitmo())
def(noteRitmo, makeNoteRitmo())
def(noteHolder, mk(SampleHold, 100::ms))
def(speedScaler, mk(PulseDiv, 1))
def(globalOffset, mk(Offset, 0))
def(localOffset, mk(Offset, 0))
def(staticOffset, mk(Offset, 0))
def(finalDelay, mk(PulseDelay, 0))
def(scaleMapper, mk(Mapper, Scales.MinorNatural, 12))


P(Runner.masterClock)
  .b(finalDelay.to(P_Clock))
  => speedScaler.c
  => pulseRitmo.c
  => noteRitmo.c
  => noteHolder.to(P_Set).listen(P_Trigger).c
  => globalOffset.c
  => localOffset.c
  => staticOffset.c
  => finalDelay.c
  => scaleMapper.c
  => mk(Printer, "out").c
  => out.c
;


// MAPPINGS

def(nanoktrl, mk(MidInp, MIDI_IN_NANO_KTRL, 0));

nanoktrl
  => mk(RangeMapper, 0, 127, 0, Util.toSamples(1::second)).from("cc14").c
  => noteHolder.to("holdTime").c
;



def(launchpad, mk(MidInp, MIDI_IN_LAUNCHPAD, 0))

for(0=>int i;i<7;++i){
  launchpad => pulseRitmo.fromTo("note"+i, ""+i).c;
}

for(16=>int i;i<21;++i){
  launchpad => pulseRitmo.fromTo("note"+i, ""+(i-16+7)).c;
}

/* launchpad => mk(Printer, "note").from("note").c; */
nanoktrl => mk(Printer, "nanoktrl note").from("note").c;
nanoktrl => mk(Printer, "nanoktrl cc").from("cc").c;

launchpad => noteRitmo.fromTo("note112", "0").c;
launchpad => noteRitmo.fromTo("note113", "1").c;



Runner.setPlaying(1);

Util.runForever();

