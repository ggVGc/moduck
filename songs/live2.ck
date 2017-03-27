
include(song_macros.m4)
include(_all_instruments.m4)

def(out1, mk(Repeater));
def(out2, mk(Repeater));

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




playBlocker1 => out1.c;
playBlocker2 => out2.c;



Runner.masterClock
  => mk(PulseDiv, B).c
  => metronome.c
;


def(lpOut, mk(NoteOut, MIDI_OUT_LAUNCHPAD, 0, false));

def(circuit1, mk(NoteOut, MIDI_OUT_CIRCUIT, 0, false));
def(circuit2, mk(NoteOut, MIDI_OUT_CIRCUIT, 1, false));
out1 => circuit1.c;
out2 => circuit2.c;

keysIn => toggler.c;

toggler
  .b(out1.from("0"))
  .b(out2.from("1"))
;
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


oxygen
  => recRouter.from("note").c
;


for(0=>int i;i<4;++i){
  launchpad
    => mk(Value, i).from("cc"+(104+i)).c
    => recRouter.to("index").c
  ;
}

recRouter => mk(Printer, "new index").from(recv("index")).c;


launchpad
  => mk(Value, 0).from("cc104").c
  => recRouter.to("index").c
;

launchpad
  => mk(Value, 0).from("cc104").c
  => recRouter.to("index").c
;

launchpad => toggler.fromTo("note118", P_Toggle).c;
/* launchpad => holder2.from("note119").c; */

oxygen => keysIn.from("note").c;

playBlocker1
  => mk(Value, 118).from(recv(P_Gate)).c
  => lpOut.c
;

playBlocker2
  => mk(Value, 119).from(recv(P_Gate)).c
  => lpOut.c
;


Runner.setPlaying(1);
Util.runForever();
