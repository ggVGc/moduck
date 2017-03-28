
include(song_macros.m4)
include(_all_instruments.m4)




fun ModuckP makeSeqThing(int sequenceCount, int outCount){
  [P_Trigger, "seqInd"] @=> string rootTags[];
  string outTags[0];
  for(0=>int i;i<outCount;++i){
    rootTags << "toggleOut"+i;
    outTags << ""+i;
  }
  def(root, mk(Repeater, rootTags));
  def(out, mk(Repeater, outTags));
  def(seqRouter, mk(Router));

  ModuckP outBlockers[outCount];
  for(0=>int i;i<outCount;++i){
    def(blocker, mk(Blocker));
    blocker @=> outBlockers[i];
    def(toggler, mk(Toggler));
    toggler => blocker.fromTo("1", P_Gate).c;
    root => toggler.fromTo("toggleOut"+i, P_Toggle).c;
    seqRouter
      => blocker.c
      => out.to(""+i).c
    ;
  }

  root
    => seqRouter.c
  ;

  for(0=>int i;i<sequenceCount;++i){
    root => seqRouter.fromTo("seqInd", "index").c;
  }

  return mk(Wrapper, root, out);
}


def(thing1, makeSeqThing(4,2));
/* def(thing2, makeSeqThing()); */

def(keysIn, mk(Repeater));

def(metronome, mk(Repeater));





defl(bufs,
    mk(Buffer),
    mk(Buffer),
    mk(Buffer),
    mk(Buffer)
);

def(recRouter, mk(Router, 0));
keysIn => recRouter.c;


for(0=>int elemInd;elemInd<bufs.size();++elemInd){
  bufs[elemInd] @=> ModuckP buf;
  recRouter => buf.fromTo(""+elemInd, P_Set).c;
}


def(holder1, mk(SampleHold));
def(holder2, mk(SampleHold));


def(playBlocker1, mk(Blocker));
def(playBlocker2, mk(Blocker));

holder1 =>  playBlocker1.to(P_Gate).c;
holder2 =>  playBlocker2.to(P_Gate).c;

/* def(switcher, mk(Switcher)); */
def(toggler, mk(Toggler));





Runner.masterClock
  => mk(PulseDiv, B).c
  => metronome.c
;


def(lpOut, mk(NoteOut, MIDI_OUT_LAUNCHPAD, 0, false));

def(circuit1, mk(NoteOut, MIDI_OUT_CIRCUIT, 0, false));
def(circuit2, mk(NoteOut, MIDI_OUT_CIRCUIT, 1, false));
thing1 => circuit1.from("0").c;
thing1 => circuit2.from("1").c;
/* thing2 => circuit2.c; */

/* keysIn => toggler.c; */

/* 
 toggler
   .b(out1.from("0"))
   .b(out2.from("1"))
 ;
 */
/* 
 keysIn
   .b(playBlocker1)
   .b(playBlocker2)
 ;
 */



// MAPPINGS


def(launchpad, mk(MidInp, MIDI_IN_LAUNCHPAD, 0))
def(oxygen, mk(MidInp, MIDI_IN_OXYGEN, 0));
oxygen => lpOut.from("note").c;




/* metronome */
/*   => mk(Printer, "TICK").c */
/* ; */


/* nanoktrl => mk(Printer, "nanoktrl note").from("note").c; */
/* nanoktrl => mk(Printer, "nanoktrl cc").from("cc").c; */
/* launchpad => mk(Printer, "lp note").from("note").c; */
/* launchpad => mk(Printer, "lp cc").from("cc").c; */
oxygen => mk(Printer, "oxygen cc").from("cc").c;


(oxygen => mk(Repeater).from("note").c)
  .b(thing1)
  /* .b(thing2) */
;

launchpad
  .b((mk(Value, 0) => thing1.to("seqInd").c).from("cc104"))
  .b((mk(Value, 1) => thing1.to("seqInd").c).from("cc105"))
  .b((mk(Value, 2) => thing1.to("seqInd").c).from("cc106"))
  .b((mk(Value, 3) => thing1.to("seqInd").c).from("cc107"))
;


launchpad => thing1.fromTo("cc110", "toggleOut0").c;
launchpad => thing1.fromTo("cc111", "toggleOut1").c;
  /* .b(thing1.fromTo("cc111", "toggleOut1")) */



/* 
 for(0=>int i;i<4;++i){
   launchpad
     => mk(Value, i).from("cc"+(104+i)).c
     => recRouter.to("index").c
   ;
 }
 */

recRouter => mk(Printer, "new index").from(recv("index")).c;


/* 
 launchpad
   => mk(Value, 0).from("cc104").c
   => recRouter.to("index").c
 ;
 
 launchpad
   => mk(Value, 0).from("cc104").c
   => recRouter.to("index").c
 ;
 */

/* launchpad => thing1.fromTo("note112", P_Toggle).c; */
/* launchpad => holder2.from("note119").c; */

/* oxygen => keysIn.from("note").c; */

playBlocker1
  => mk(Value, 118).from(recv(P_Gate)).c
  => lpOut.c
;

playBlocker2
  => mk(Value, 119).from(recv(P_Gate)).c
  => lpOut.c
;

MidiMsg msg;
MidiOut midOut;
midOut.open(MIDI_IN_LAUNCHPAD) => int succ;
176 => msg.data1;
midOut.send(msg);

Runner.setPlaying(1);
Util.runForever();



