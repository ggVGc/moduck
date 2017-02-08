fun Moduck noteDiddler(int port, dur maxNoteDur, int noteValues[], int noteIndices[], int noteDivs[], float durationRatios[], Moduck noteProcessor){
  Repeater.make() @=> Repeater parent;
  
  Sequencer.make(noteIndices, true) @=> Sequencer noteSeq;
  Sequencer.make(noteDivs, true) @=> Sequencer noteDivSeq;
  Util.ratios(0, 127, durationRatios) @=> int durations[];
  Sequencer.make(durations, true) @=> Sequencer durationSeq;

  PulseDiv.make(durations[0], true) @=> PulseDiv divider;
  V(noteDivSeq, divider, "divisor");
  C(parent, divider) @=> Moduck divClock;

  multi( divClock, [
    X(noteDivSeq)
    ,X(durationSeq)
  ]);

  NoteOut.make(port, 0, 0::ms, maxNoteDur)
    @=> NoteOut noteOut;

  V(durationSeq, noteOut, "durRatio");

  Moduck @ out;

  if(noteProcessor != null){
    C(noteProcessor, noteOut) @=> out;
  }else{
    noteOut @=> out;
  }


  return Wrapper.make(parent, 
    chain(divClock, [
      X(noteSeq)
      ,X(Mapper.make(noteValues, 12))
      ,X(out)
    ]));
}
