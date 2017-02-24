include(song_macros.m4)
include(_all_parts.m4)

Runner.setPlaying(1);
Runner.setBpm(108);

def(synth, mk(NoteOut, MIDI_OUT_IAC_3, 0, 0::ms, D16, false))
def(synth2, mk(NoteOut, MIDI_OUT_IAC_1, 0, 0::ms, D16, false))

def(clap, mk(NoteOut, MIDI_OUT_IAC_2, 1, 0::ms, D4, true)
  .set("note", 4)
)

def(kick,
  mk(NoteOut, MIDI_OUT_IAC_2, 0, 0::ms, D4, true)
  .set("note", 0)
)

def(beatMeta, metaSeq("0", B+B3, Bar*4, [
  mk(PulseDiv, B3, 0)
  ,mk(PulseDiv, B6, 0)
  ,mk(PulseDiv, B3, 0)
  ,mk(PulseDiv, B4, 0)
]))


dnl // def(meloMeta, metaSeq("0...1...2", Bar/2, Bar*6, [
dnl //  mk(Sequencer, [0,1,2]).b(mk(Printer, "reset").from(recv(P_Reset)))
dnl //  ,mk(Sequencer, [1,2,4])
dnl //  ,mk(Sequencer, [-1,-3,-2])
dnl // ]).set("resetOnLoop", true))


def(meloRouter, mk(Router, 0).propagate(P_Reset).multi([
  mk(Sequencer, [0,1,2]).from("0").listen(P_Reset)
  ,mk(Sequencer, [1,2,4]).from("1").listen(P_Reset)
  ,mk(Sequencer, [-1,-3,-2]).from("2").listen(P_Reset)
]))

def(blocker, mk(Router, 0).multi([
  mk(Blackhole).from("0")
  ,mk(Repeater).from("1")
]))


def(master, Runner.masterClock => blocker.c)


master.multi([
  beatMeta.to(P_Clock)
  // , meloMeta.to(P_Clock)
]);



master
  => beatMeta.c
  // => meloMeta.c
  => meloRouter.c
  => mkc(Mapper, Scales.MinorNatural, 12)
  => octaves(4).c => mkc(Offset, -4)
  => synth.c
;


def(resetter, mk(Repeater, P_Reset))

master
  => seqDiv("..11", B4, Bar).hook(resetter.listen(P_Reset)).c
  => metaSeq("001", Bar, Bar*3, [mk(Value, -4), mk(Value, 3)]).hook(resetter.listen(P_Reset)).hook(master.to(P_Clock)).c
  => octaves(5).c
  => synth2.c
;



def(blockerOff, mk(Value, 1) => blocker.to("index").c);
def(blockerOn, mk(Value, 0) => blocker.to("index").c);

def(kickGen, fourFour(B, 70))

master => kickGen.c => kick.c;

mk(MidInp, MIDI_IN_IAC_6, 0)
  .b(resetter.from("cc"))
  .b(blockerOff.from("noteOn"))
  .b(meloRouter.fromTo("cc", P_Reset))
  .b((mk(Delay, samp) => meloRouter.to("index").c).from("noteOn"))
  .b(beatMeta.fromTo("noteOn", P_Reset))
  .b(meloRouter.fromTo("noteOn", P_Reset))
  .b(beatMeta.fromTo("cc", P_Reset))
  .b(kickGen.fromTo("cc", P_Reset))
  .b(blockerOn.from("cc"))
;



Util.runForever();
