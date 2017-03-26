include(song_macros.m4)

def(buf,
  mk(Buffer, D*48)
);

def(keys, mk(MidInp, MIDI_IN_OXYGEN, 0));
def(launchpad, mk(MidInp, MIDI_IN_LAUNCHPAD, 0));
def(out, mk(NoteOut, MIDI_OUT_CIRCUIT, 0, false));
def(out2, mk(NoteOut, MIDI_OUT_CIRCUIT, 0, false));


launchpad => mk(Printer, "lp cc").from("cc").c;
/* keys => mk(Printer, "oxygen cc").from("cc").c; */

launchpad => buf.fromTo("cc104", P_Clear).c;


keys => out.fromTo("cc7", "velocity").c;

def(pulse, mk(PulseDiv, Bar*2));

Runner.masterClock
 => pulse.c
;

/* 
 Runner.masterClock
   => mk(PulseDiv, B).c
   => mk(Offset, 40).c
   => mk(SampleHold, 50::ms).c
   => out.c
 ;
 */

pulse
 => buf.to(P_Reset).c
;


keys => out.from("note").c;


/* keys => buf.fromTo("note", P_Set).c; */

/* 
 pulse
   => mk(Offset, 42).c
   => mk(Delay, 100::ms).c
   => buf.to(P_Set).c
 ;
 */

Runner.masterClock
  => buf.to(P_Trigger).c
  => mk(Printer, "").c
  => out2.c
;



Runner.setPlaying(1);

Util.runForever();

