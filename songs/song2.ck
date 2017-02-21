


134 => BPM;


output(synth, MIDI_OUT_IAC_3, 0, 16, false) 
output(synth2, MIDI_OUT_IAC_3, 1, 4, false) 
output(synth3, MIDI_OUT_IAC_3, 2, 4, false) 

def(clap, mk(NoteOut, MIDI_OUT_IAC_2, 1, 0::ms, D4, true)
  .set("note", 4)
)

def(kick,
  mk(NoteOut, MIDI_OUT_IAC_2, 0, 0::ms, D4, true)
  .set("note", 0)
)


def(beatMeta, metaSeq("0123110231211020210", B+B3, Bar*4, [
  mk(PulseDiv, B2, 0)
  ,mk(PulseDiv, B6, 0)
  ,mk(PulseDiv, B3, 0)
  ,mk(PulseDiv, B4, 0)
]))


def(meloMeta, metaSeq("012.", Bar, Bar/2, [
 mk(Sequencer, [0,1,2])
 ,mk(Sequencer, [4,3,4])
 ,mk(Sequencer, [2,6,5])
])
)

samp => now;

// meloMeta.set("resetOnLoop", true);


masterClock
  .b(beatMeta.to(P_Clock))
  .b(meloMeta.to(P_Clock))
;

masterClock
  => beatMeta.c
  /*
    => mk(Sequencer, [0,1,2,3,2,3,1,0,-2,-1]).hook(
        beatMeta.fromTo(P_Looped, P_Reset)
      ).c
   */
  => meloMeta.c
  // => mkc(Printer, "note")
  => mkc(Mapper, Scales.MinorNatural, 12)
  => octaves(3).c => mkc(Offset, -2)
  => synth.c
;

masterClock => fourFour(B, 70).c => kick.c;


1 => PLAY;

