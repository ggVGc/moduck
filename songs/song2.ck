include(song_macros.m4)
include(_all_parts.m4)

Runner.setPlaying(0);

/*
  setBpm(134);
  setTicksPerBeat(32);
 */


Runner.setBpm(108);


output(synth2, MIDI_OUT_IAC_3, 1, 4, false) 
output(synth3, MIDI_OUT_IAC_3, 2, 4, false) 


def(synth, mk(NoteOut, MIDI_OUT_IAC_3, 0, 0::ms, D16, false))

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


def(meloRouter, mk(Router, 0).multi([
  mk(Sequencer, [0,1,2]).from("0")
  ,mk(Sequencer, [1,2,4]).from("1")
  ,mk(Sequencer, [-1,-3,-2]).from("2")
]))




P(Runner.masterClock)
  .b(beatMeta.to(P_Clock))
  // .b(meloMeta.to(P_Clock))
;

Runner.masterClock
  /*
    => mk(Sequencer, [0,1,2,3,2,3,1,0,-2,-1]).hook(
        beatMeta.fromTo(P_Looped, P_Reset)
      ).c
   */
  => beatMeta.c
  // => meloMeta.c
  => meloRouter.c
  // => mkc(Printer, "note")
  => mkc(Mapper, Scales.MinorNatural, 12)
  => octaves(4).c => mkc(Offset, -4)
  => synth.c
;


Runner.masterClock => fourFour(B, 70).c => kick.c;



Runner.masterClock
  => mkc(Delay, D*8)
  => mkc(Value, 1)
  => meloRouter.to("index").c
;


Util.runForever();
