
include(song_macros.m4)


Runner.masterClock
  => mk(PulseDiv, 64).c
  => MBUtil.onlyHigh().c
  => mk(Printer, "AAA").c;
  /* => mk(SampleHold, 50::ms).c */
  /* => mk(Offset, 60).c */

  /* => mk(NoteOut, openOut(MIDI_OUT_CIRCUIT), 0).c; */


openOut(MIDI_OUT_CIRCUIT) @=> MidiOut out;
MidiMsg msg;
144 => msg.data1; // NoteOn

60 => msg.data2;
100 => msg.data3;


fun void off(){

  30::ms => now;

  MidiMsg m;
  128 => m.data1; // NoteOn

  60 => m.data2;
  120 => m.data3;
  out.send(m);
}


fun void foo(){
  while(true){
    <<<"BBB: "+(Math.floor(now/samp)$int)>>>;
    minute/120 => now;
    /* out.send(msg); */
    /* spork ~ off(); */
  }
}

Runner.setPlaying(true);
spork ~ foo();

Util.runForever();




