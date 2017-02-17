


138 => BPM;


output(bass, MIDI_OUT_IAC_1, 0, 8) 
output(bass2, MIDI_OUT_IAC_1, 0, 32) 

output(drums, MIDI_OUT_IAC_2, 0, 4)
output(hatsDrums, MIDI_OUT_IAC_2, 0, 4)

output(drums2, MIDI_OUT_IAC_2, 1, 4)



def( rootNotes, S([0, -4, -2, -3], true) )
// [B, B2, B4, B2, B2] @=> int gateLens[];
[B4, B2, B4] @=> int gateLens[];
// [B*4, B4, B*2, B*2, B*2, B*2] @=> int noteLens[];
[B*8, B*4, B2, B*3+B2] @=> int noteLens[];

def(gateDivider, seqDiv(gateLens))
def(noteDivider, seqDiv(noteLens))

noteDivider
  .c(Buffer.make(1)) // Skip stepping note on first trigger
  .c(rootNotes, P_Step);


gateDivider.c(rootNotes, P_Trigger);


def(diddles,
  rootNotes
    .c(Mapper.make(Scales.MinorNatural, 12))
    .c(octaves(4))
    .c(Offset.make(-3))
    // ,X(Printer.make("NoteOut: "))
    .c(mk(Delay, TIME_PER_BEAT/4))
    // ,X(Offset.make(3))
)

diddles.multi([
  X(bass)
  // ,X(C(Delay.make(80::ms), bass))
  // ,X(C(Delay.make(200::ms), bass))
]);

fun ModuckP claps(){
  return
    fourFour(B*2, 4)
    .c(Delay.make(D2));
}


fun Moduck hats(){
  def(hatsVels, S(Util.ratios(0,115,[1.0, 0.7]), true))
  V(hatsVels, hatsDrums, "velocity");
  samp => now;
  hatsVels.doHandle(P_StepTrigger, 0);
  C(hatsDrums, hatsVels);

  return
    fourFour(B, 7)
    .multi([
      X(Delay.make(D2))
      ,X(Delay.make(D8))
    ])
    .c(hatsDrums);

}




masterClock
  .b(noteDivider)
  // ,X(C(Delay.make(samp), gateDivider)) // Always trigger gate after note change
  .b( fourFour(B, 0).c(drums) )
  // ,X(C(C(Delay.make(D32), fourFour(B, 70)), drums))
  // ,X(C(C(Delay.make(D32), fourFour(B, 60)), drums))
  // ,X(C(Delay.make(D2),
  .b( mk(Delay, D4).c(hats()) )
  .b(
    claps()
      .b( mk(Value, 110).v(drums, "velocity") )
      // .c(Patch.thru( V(Value.make(110), drums, "velocity")))
      .c(drums)
  )
;




1 => PLAY;
