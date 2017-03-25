
include(song_macros.m4)
include(_all_parts.m4)
include(_all_instruments.m4)

[ fourFour(B*2, 0)
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
] @=> ModuckP pulseRitmoRhythms[];

fun ModuckP makePulseRitmo(){
  def(rit, ritmo(true, pulseRitmoRhythms));
  return rit;
}

fun ModuckP makeNoteRitmo(){
  def(rit, ritmo(true, [
    mk(Value, 0)
    ,mk(Sequencer, [0,0,2,2])
    ,mk(Sequencer, [0,1,2])
    ,mk(Sequencer, [3,4,5])
  ]));


  return rit;
}

def(out, mk(Repeater));

def(pulseRitmo, makePulseRitmo())
def(noteRitmo, makeNoteRitmo())
def(noteHolder, mk(SampleHold, 100::ms))
def(speedScaler, mk(PulseDiv, 2))
def(globalOffset, mk(Offset, 0))
def(localOffset, mk(Offset, 0))
def(staticOffset, mk(Offset, 0))
def(finalDelay, mk(PulseDelay, 10))
def(scaleMapper, mk(Mapper, Scales.MinorNatural, 12))
/* def(octaver, mk(Offset, 0)) */

def(octaveOffset, mk(Offset, 3*12));
def(rootNoteOffset, mk(Offset, 0));

for(0=>int i;i<pulseRitmoRhythms.size();++i){
  pulseRitmo => noteRitmo.fromTo(recv(""+i), P_Reset).c;
}

P(Runner.masterClock)
  .b(finalDelay.to(P_Clock))
  => mk(PulseGen, 2, Runner.timePerTick()/2).c
  => speedScaler.c
  => pulseRitmo.c
  => noteRitmo.c
  => noteHolder.to(P_Set).listen(P_Trigger).c
  => globalOffset.c
  => localOffset.c
  => staticOffset.c
  => finalDelay.c
  => scaleMapper.c
  /* => (octaver => mk(Mul, 12).c).c */
  => octaveOffset.c
  => rootNoteOffset.c
  => mk(Printer, "out").c
  => out.c
;



// MAPPINGS

def(launchpad, mk(MidInp, MIDI_IN_LAUNCHPAD, 0))
/* def(nanoktrl, mk(MidInp, MIDI_IN_NANO_KTRL, 0)); */
def(oxygen, mk(MidInp, MIDI_IN_OXYGEN, 0));
def(circuit, mk(NoteOut, MIDI_OUT_CIRCUIT, 0, false));

/* launchpad => mk(Printer, "note").from("note").c; */
/* nanoktrl => mk(Printer, "nanoktrl note").from("note").c; */
/* nanoktrl => mk(Printer, "nanoktrl cc").from("cc").c; */
oxygen => mk(Printer, "oxygen cc").from("cc").c;

out => circuit.c;

oxygen
  => mk(RangeMapper, 0, 127, 0, Util.toSamples(500::ms)).from("cc74").c
  => noteHolder.to("holdTime").c
;

oxygen
  => mk(RangeMapper, 0, 127, 0, 24).from("cc73").c
  => staticOffset.to("offset").c
;

oxygen
  => mk(RangeMapper, 0, 127, 0, 200).from("cc84").c
  => speedScaler.to("scaling").c
;


oxygen
  => finalDelay.fromTo("cc72", "size").c
;


/* 
 nanoktrl
   => mk(RangeMapper, 0, 127, 0, 6).from("cc16").c
   => octaver.to("value").c
 ;
 */



for(0=>int i;i<7;++i){
  launchpad => pulseRitmo.fromTo("note"+i, ""+i).c;
}

for(16=>int i;i<21;++i){
  launchpad => pulseRitmo.fromTo("note"+i, ""+(i-16+7)).c;
}


launchpad => noteRitmo.fromTo("note32", "0").c;
launchpad => noteRitmo.fromTo("note33", "1").c;


Runner.setPlaying(1);

Util.runForever();

