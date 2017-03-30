
include(song_macros.m4)
include(_all_instruments.m4)


// TODO: this is just a bad special case of Ritmo..
fun ModuckP makeRecBufs(int count){
  def(root, mk(Repeater, [P_Trigger, P_Reset, P_Gate, "index", "rec"]));
  def(out, mk(Repeater, [P_Trigger]));
  def(playRouter, mk(Router, 0));
  def(recRouter, mk(Router, 0));
  def(recBlocker, mk(Blocker));
  root
    .b(playRouter.listen("index"))
    .b(recRouter.listen("index"))
    .b(recBlocker.fromTo("rec", P_Gate))
    .b(out.fromTo(P_Gate, P_Trigger)) // Play notes that we receive, even if not recording
  ;
  root
    => recBlocker.from(P_Gate).c
    => recRouter.c
  ;

  ModuckP bufs[count];
  for(0=>int i;i<count;++i){
    mk(Buffer) @=> ModuckP buf;
    buf @=> bufs[i];
    root => buf.listen([P_Reset, P_Trigger]).c;
    playRouter
      .b(buf.fromTo(recv("index"), P_Reset))
      .b((buf => out.c).from(""+i));
    recRouter => buf.fromTo(""+i, P_Set).c;
    buf => out.c;
  }

  return mk(Wrapper, root, out);
}


fun ModuckP makeTogglingOuts(ModuckP source, int outCount){
  [P_Trigger] @=> string rootTags[];
  string outTags[0];
  for(0=>int i;i<outCount;++i){
    rootTags << "toggleOut"+i;
    outTags << "outActive"+i;
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
    toggler => mk(Inverter, 0).c => out.to("outActive"+i).c;
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


def(bufResetter, mk(Repeater));
ModuckP outs[0];
ModuckP bufs[0];
ModuckP recToggles[0];
for(0=>int i;i<4;++i){
  makeRecBufs(4) @=> ModuckP b;
  Runner.masterClock => b.c;
  bufs << b;
  keysIn => b.to(P_Gate).c;
  bufResetter => b.to(P_Reset).c;
  def(out, makeTogglingOuts(b, 2));
  outs << out;

  def(recTog, mk(Toggler) => mk(Inverter, 0).c);
  recTog => b.to("rec").c;
  def(recTogRep, mk(Repeater));
  recTogRep => recTog.to(P_Toggle).c;
  recToggles << recTogRep;

  Runner.masterClock => out.c;
}


Runner.masterClock
  => mk(PulseDiv, Bar*2).c
  => bufResetter.c
;


// OUTPUTS

def(lpOut, mk(NoteOut, MIDI_OUT_LAUNCHPAD, 0, false));
def(circuit1, mk(NoteOut, MIDI_OUT_CIRCUIT, 0, false));
def(circuit2, mk(NoteOut, MIDI_OUT_CIRCUIT, 1, false));

for(0=>int outInd;outInd<outs.size();++outInd){
  outs[outInd]
    .b(circuit1.from("0"))
    .b(circuit2.from("1"))
  ;
}


// DEVICES

def(launchpad, mk(MidInp, MIDI_IN_LAUNCHPAD, 0))
def(oxygen, mk(MidInp, MIDI_IN_OXYGEN, 0));


// MAPPINGS

/* nanoktrl => mk(Printer, "nanoktrl note").from("note").c; */
/* nanoktrl => mk(Printer, "nanoktrl cc").from("cc").c; */
launchpad => mk(Printer, "lp note").from("note").c;
/* launchpad => mk(Printer, "lp cc").from("cc").c; */
oxygen => mk(Printer, "oxygen cc").from("cc").c;
oxygen => mk(Printer, "oxygen note").from("note").c;
oxygen => lpOut.from("note").c;


oxygen => keysIn.from("note").c;


for(0=>int outInd;outInd<outs.size();++outInd){
  oxygen => outs[outInd].from("note").c;
}


launchpad
  .b((mk(Value, 0) => bufs[0].to("index").c).from("note0"))
  .b((mk(Value, 1) => bufs[0].to("index").c).from("note1"))
  .b((mk(Value, 2) => bufs[0].to("index").c).from("note2"))
  .b((mk(Value, 3) => bufs[0].to("index").c).from("note3"))
;

launchpad => recToggles[0].from("note5").c;
launchpad => outs[0].fromTo("note6", "toggleOut0").c;
launchpad => outs[0].fromTo("note7", "toggleOut1").c;

/* 
 launchpad
   .b((mk(Value, 0) => bufs[1].to("index").c).from("note0"))
   .b((mk(Value, 1) => bufs[1].to("index").c).from("note1"))
   .b((mk(Value, 2) => bufs[1].to("index").c).from("note2"))
   .b((mk(Value, 3) => bufs[1].to("index").c).from("note3"))
 ;
 
 
 launchpad => recToggles[1].from("note5").c;
 launchpad => outs[1].fromTo("note6", "toggleOut0").c;
 launchpad => outs[1].fromTo("note7", "toggleOut1").c;
 */


fun void mkToggleIndicator(ModuckP src, string tag,int noteNum){
  def(indicator, mk(TrigValue, noteNum) => mk(NoteOut, MIDI_OUT_LAUNCHPAD, 0, false).c);
  src => indicator.from(tag).c;
}


mkToggleIndicator(bufs[0], recv("rec"), 5);
mkToggleIndicator(outs[0], "outActive0", 6);
mkToggleIndicator(outs[0], "outActive1", 7);




/* mkToggleIndicator(bufs[1], recv("rec"), 16+5); */
/* mkToggleIndicator(bufs[2], recv("rec"), 16*2+5); */
/* mkToggleIndicator(bufs[3], recv("rec"), 16*3+5); */


// Send launchpad reset message
MidiMsg msg;
MidiOut midOut;
midOut.open(MIDI_IN_LAUNCHPAD) => int succ;
176 => msg.data1;
midOut.send(msg);

Runner.setPlaying(1);
Util.runForever();
