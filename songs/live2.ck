
include(song_macros.m4)
include(_all_instruments.m4)


/* 
 def(srcRouter, mk(Router));
 root => srcRouter.listen(P_Trigger).fromTo("srcInd", "index").c;
  for(0=>int elemInd;elemInd<sources.size();++elemInd){
    sources[elemInd] @=> ModuckP src;
    srcRouter => src.from(""+elemInd).c;
    src => srcOut.c;
  }
 */


fun ModuckP makeRecBufs(int count){
  def(root, mk(Repeater, [P_Trigger, "index", "rec"]));
  def(out, mk(Repeater, [P_Trigger]));
  def(router, mk(Router, 0));
  def(recBlocker, mk(Blocker));
  root => router.listen("index").c;
  root => recBlocker.fromTo("rec", P_Gate).c;
  ModuckP bufs[count];
  for(0=>int i;i<count;++i){
    mk(Buffer) @=> ModuckP b;
    b @=> bufs[i];

    router
      => b.from(""+count).c
      => out.c;
    recBlocker => b.to(P_Set).c;
  }

  return mk(Wrapper, root, out);
}


fun ModuckP makeTogglingOuts(ModuckP source, int outCount){
  [P_Trigger, "srcInd"] @=> string rootTags[];
  string outTags[0];
  for(0=>int i;i<outCount;++i){
    rootTags << "toggleOut"+i;
    outTags << ""+i;
  }
  def(root, mk(Repeater, rootTags));
  def(out, mk(Repeater, outTags));

  ModuckP outBlockers[outCount];
  for(0=>int i;i<outCount;++i){
    def(blocker, mk(Blocker));
    blocker @=> outBlockers[i];
    def(toggler, mk(Toggler));
    toggler => blocker.fromTo("1", P_Gate).c;
    root => toggler.fromTo("toggleOut"+i, P_Toggle).c;
    source
      => blocker.c
      => out.to(""+i).c
    ;
  }


  return mk(Wrapper, root, out);
}

def(metronome, mk(Repeater));
Runner.masterClock
  => mk(PulseDiv, B).c
  => metronome.c
;


def(keysIn, mk(Repeater));


makeRecBufs(4) @=> ModuckP bufs;
Runner.masterClock => bufs.c;
def(thing1, makeTogglingOuts(bufs, 2));
/* def(thing2, makeTogglingOuts()); */

keysIn => thing1.c;
Runner.masterClock => thing1.c;


/* 
 for(0=>int bufInd;bufInd<bufs.size();++bufInd){
   bufs[bufInd] @=> ModuckP buf;
   recRouter => buf.fromTo(""+bufInd, P_Set).c;
 }
 */



def(lpOut, mk(NoteOut, MIDI_OUT_LAUNCHPAD, 0, false));

def(circuit1, mk(NoteOut, MIDI_OUT_CIRCUIT, 0, false));
def(circuit2, mk(NoteOut, MIDI_OUT_CIRCUIT, 1, false));
thing1
=> mk(Repeater).from("0").c
=> mk(Value, 60).c
=> mk(SampleHold, 100::ms).to(P_Set).listen(P_Trigger).c
=> circuit1.c;

thing1
=> mk(Repeater).from("1").c
=> mk(Value, 42).c
=> mk(SampleHold, 100::ms).to(P_Set).listen(P_Trigger).c
=> circuit2.c;

/* thing1 => circuit2.from("1").c; */


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
  .b((mk(Value, 0) => thing1.to("srcInd").c).from("cc104"))
  .b((mk(Value, 1) => thing1.to("srcInd").c).from("cc105"))
  .b((mk(Value, 2) => thing1.to("srcInd").c).from("cc106"))
  .b((mk(Value, 3) => thing1.to("srcInd").c).from("cc107"))
;

launchpad => thing1.fromTo("cc110", "toggleOut0").c;
launchpad => thing1.fromTo("cc111", "toggleOut1").c;

oxygen => keysIn.from("note").c;

MidiMsg msg;
MidiOut midOut;
midOut.open(MIDI_IN_LAUNCHPAD) => int succ;
176 => msg.data1;
midOut.send(msg);

Runner.setPlaying(1);
Util.runForever();



