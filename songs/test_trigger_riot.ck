include(song_macros.m4)
include(_all_parts.m4)

Runner.setPlaying(1);

def(synth, mk(NoteOut, MIDI_OUT_IAC_1, 0, 0::ms, D4, false))
def(kick,

  mk(NoteOut, MIDI_OUT_IAC_2, 0, 0::ms, D4, true)
  .set("note", 0)
)

def(snare, mk(NoteOut, MIDI_OUT_IAC_2, 0, 0::ms, D4, true)
  .set("note", 1)
)
def(hat, mk(NoteOut, MIDI_OUT_IAC_2, 0, 0::ms, D4, true)
  .set("note", 2)
)

def(riot, triggerRiot(4, B4))

Runner.masterClock
  => riot.c
;


/*
  Runner.masterClock
    => mk(PulseDiv, B4).c
    => MUtil.process(mk(Value, 0), "value", mk(Add, 1)).c
    => (mk(RangeMapper, 0,127,50,60) => mkc(Printer, "rangemapped: ")).c
  ;
 */

def(nanoKtrl, mk(MidInp, MIDI_IN_NANO_KTRL, 0))
def(nanoKtrl2, mk(MidInp, MIDI_IN_NANO_KTRL, 1))

for(0=>int x;x<3;++x){
  for(0=>int y;y<3;++y){
    x+y*3 @=> int ind;
    nanoKtrl => (mk(RangeMapper, 0,127,0,64) => riot.to("div"+x+""+y).c).from("ccOn"+(14+ind)).c;
    riot => mk(Printer, "div "+x+" "+y).from(recv("div"+x+""+y)).c;

    nanoKtrl => (mk(RangeMapper, 0,127,0,100) => riot.to("prob"+x+""+y).c).from("ccOn"+(2+ind)).c;
    riot => mk(Printer, "prob "+x+" "+y).from(recv("prob"+x+""+y)).c;

    nanoKtrl
      => MUtil.process(riot, recv("delay"+x+""+y), "delay"+x+""+y, mk(Add, 1))
          .from("ccOn"+(23+ind)).c
    ;
    nanoKtrl
      => MUtil.process(riot, recv("delay"+x+""+y), "delay"+x+""+y, mk(Add, -1) => mkc(RangeMapper, 0,9999,0,9999))
          .from("ccOn"+(33+ind)).c
    ;
    riot => mk(Printer, "delay "+x+" "+y).from(recv("delay"+x+""+y)).c;

    nanoKtrl2
      => (mk(RangeMapper, 0,127,0,100) => riot.to("time"+x+""+y).c).from("ccOn"+(57+ind)).c;
    ;
    riot => mk(Printer, "time "+x+" "+y).from(recv("time"+x+""+y)).c;


    nanoKtrl2
      => riot.from("ccOn"+(48+ind)).to("speed"+x+""+y).c
    ;
    riot => mk(Printer, "speed "+x+" "+y).from(recv("speed"+x+""+y)).c;
  }
}

nanoKtrl => mk(Printer, "ccOn").from("ccOn").c;
nanoKtrl2 => mk(Printer, "ccOn").from("ccOn").c;



// riot
//   .set("div00", 4)
//   .set("div10", 9)
//   .set("div13", 5)
//   .set("div12", 14)
//   .set("div01", 16)
//   .set("div02", 3)
//   .set("div32", 7)
//   .set("div33", 11)
//   .set("delay01", 4)
  // .set("div10", 8)
  // .set("time01", 1) // 50% time delay
// ;

// riot.set("prob01", 40);



riot.multi([
  (mk(Value, 100) => kick.c).from("side0")
  ,(mk(Value, 100) => snare.c).from("side1")
  ,(mk(Value, 100) => hat.c).from("side2")
  // ,(mk(Sequencer, [50,47,53,55,48,58]) => synth.c).from("bottom1")
  // ,mk(Printer, "side1").from("side1")
  // mk(Printer, "bottom0").from("bottom0")
  // ,mk(Printer, "bottom1").from("bottom1")
  // ,mk(Printer, "bottom2").from("bottom2")
  // ,mk(Printer, "bottom3").from("bottom3")
]);


Util.runForever();
