


138 => BPM;


output(bass, MIDI_OUT_IAC_1, 0, 8, false) 
output(bass2, MIDI_OUT_IAC_1, 0, 32, false) 
output(drums2, MIDI_OUT_IAC_2, 1, 4, false)


output(clapOut, MIDI_OUT_IAC_2, 1, 4, true)
clapOut.set("note", 4);

def(kick,
  mk(NoteOut, MIDI_OUT_IAC_2, 0, 0::ms, D4, true)
  .set("note", 0)
)


def( rootNotes, S([0, -4, -2, -3], true) )
// [B, B2, B4, B2, B2] @=> int gateLens[];
[B4, B2, B4] @=> int gateLens[];
// [B*4, B4, B*2, B*2, B*2, B*2] @=> int noteLens[];
[B*8, B*4, B2, B*3+B2] @=> int noteLens[];

def(gateDivider, seqDiv(gateLens))
def(noteDivider, seqDiv(noteLens))

noteDivider
  => mk(Buffer, 1).c // Skip stepping note on first trigger
  => rootNotes.to(P_Step).c;


gateDivider
  => rootNotes.to(P_Trigger).c;


def(diddles,
  rootNotes
    => mkc(Mapper, Scales.MinorNatural, 12)
    => octaves(4).c
    => mkc(Offset, -3)
    // ,X(Printer.make("NoteOut: "))
    => mkc(Delay, TIME_PER_BEAT/4)
    // ,X(Offset.make(3))
)




diddles
  => bass.c
  // ,X(C(Delay.make(80::ms), bass))
  // ,X(C(Delay.make(200::ms), bass))
;

fun ModuckP claps(){
  return
    fourFour(B*2, 4)
    => mkc(Delay, D2);
}



fun ModuckP hats(){
  return
    fourFour(B, 0).multi([
      mk(Delay, D8) => mkcc(Value, 100)
      ,mk(Delay, D2) => mkcc(Value, 110)
    ])
  ;
}



def(hatsOut,
  mk(NoteOut, MIDI_OUT_IAC_2, 0, 0::ms, D4, true)
  .set("note", 2)
)


def(clapDiv, mk(PulseDiv, 2, 0))

masterClock
  .b(noteDivider)
  // ,X(C(Delay.make(samp), gateDivider)) // Always trigger gate after note change
  .b( fourFour(B*3, 86).b(mk(Delay, D*2-D4-D8) => mkc(PulseDiv, 3, 0) =>kick.c) => kick.c)
  // .b( fourFour(B*3-, 0) => kick.c )
  // ,X(C(C(Delay.make(D32), fourFour(B, 70)), drums))
  // ,X(C(C(Delay.make(D32), fourFour(B, 60)), drums))
  // ,X(C(Delay.make(D2),
  .b( mk(Delay, D2) => hats().c => hatsOut.c )
  .b(
    claps()
    => clapDiv.c
    => mk(Sequencer, [70, 60, 66]).c
    => clapOut.c
    => mkc(Sequencer, [3, 2])
    => mkc(Printer, "clap divisor")
    => clapDiv.to("divisor").c
  )
;




0 => PLAY;
