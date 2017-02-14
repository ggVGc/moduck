


138 => BPM;


output(bass, MIDI_OUT_IAC_1, 8) 
output(bass2, MIDI_OUT_IAC_1, 32) 
output(drums, MIDI_OUT_IAC_2, 4)


def( rootNotes, S([0, -4, -2, -3], true) )
// [B, B2, B4, B2, B2] @=> int gateLens[];
[B4, B2, B4] @=> int gateLens[];
// [B*4, B4, B*2, B*2, B*2, B*2] @=> int noteLens[];
[B*8, B*4, B2, B*3+B2] @=> int noteLens[];

def(gateDivider, seqDiv(gateLens))
def(noteDivider, seqDiv(noteLens))

chain(noteDivider, [
  X(Buffer.make(1)) // Skip stepping note on first trigger
  ,X1(rootNotes, Pulse.Step())
]);

multi(gateDivider, [
  X1(rootNotes, Pulse.Trigger())
]);


chain(rootNotes, [
  X(Mapper.make(Scales.MinorNatural, 12))
  ,X(octaves(4))
  ,X(Offset.make(-3))
  // ,X(Printer.make("NoteOut: "))
  ,X(Delay.make(TIME_PER_BEAT/4))
  // ,X(Offset.make(3))
]) @=> Moduck diddles;

multi(diddles, [
  X(bass)
  // ,X(C(Delay.make(80::ms), bass))
  // ,X(C(Delay.make(200::ms), bass))
]);


multi(masterClock,[
  X(noteDivider)
  ,X(C(Delay.make(samp), gateDivider)) // Always trigger gate after note change
  ,X(C(fourFour(B, 90), drums))
  ,X(C(C(Delay.make(D32), fourFour(B, 70)), drums))
  ,X(C(C(Delay.make(D16), fourFour(B, 60)), drums))
]);


false => PLAY;



