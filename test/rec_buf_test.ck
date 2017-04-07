include(song_macros.m4)
include(macros.m4)

class RecBuf{
  maker0(Moduck){
    def(in, mk(Repeater, [P_Clock, P_Set, P_GoTo, P_ClearAll, P_Clear, "toggleRec"]));
    def(out, mk(Repeater, [P_Trigger, "recording", "hasData"]));

    def(buf, mk(Buffer));
    def(recWaiter, mk(OnceTrigger));
    def(recBlocker, mk(Blocker));
    def(recToggler, mk(Toggler, false));
    def(recStopDiv, mk(PulseDiv, Bar));

    def(restartBuf, mk(Value, 0) => 
        mk(Printer, "restarting buf").c
        => buf.to(P_GoTo).c);

    in => buf.listen([P_Clock, P_GoTo, P_Clear, P_ClearAll]).c;

    in
      => frm("toggleRec").c
      => recWaiter.to(P_Set).c;

    (recToggler => MBUtil.onlyHigh().c)
      .b(recStopDiv.to(P_Reset))
      .b(restartBuf.ifNot(out, "hasData"))
    ;

    in
      => frm(P_Set).c
      => recWaiter.ifNot(out, "recording").c;

    in
      => frm(P_Clock).c
      => recStopDiv.iff(out, "recording").c
      => recWaiter.c;

    recWaiter => recToggler.to(P_Toggle).c;

    recToggler
      => recBlocker.to(P_Gate).c
    ;

    in
      => frm(P_Set).c
      => mk(Delay, samp).c // Since we enable recording on Set, we need to delay a bit
      => recBlocker.c
      => buf.to(P_Set).c;

    recBlocker
      => frm(recv(P_Gate)).c
      => out.to("recording").c
    ;


    buf => out.listen("hasData").c;
    buf => out.listen(P_Trigger).c;

    samp => now;
    out.doHandle("recording", null);
    out.doHandle("hasData",null);

    return mk(Wrapper, in, out);
  }
}



def(launchpad, mk(MidInp, MIDI_IN_LAUNCHPAD, 0))
def(oxygen, mk(MidInp, MIDI_IN_OXYGEN, 0));

def(recbu, mk(RecBuf));

/* recbu => frm("hasData").to(mk(Printer, "hasData")).c; */


launchpad => mk(Printer, "did").from("cc104").c;


launchpad => frm("note0").to(recbu, P_ClearAll).c;
launchpad => frm("note1").to(recbu, P_Clear).c;
launchpad => frm("note16").to(recbu, "toggleRec").c;
launchpad => frm("note17").c => mk(Value, 0).c => recbu.to(P_GoTo).c;


Runner.masterClock => recbu.to(P_Clock).c;

recbu => mk(Printer, "Out").c;

/* oxygen => mk(Printer, "oxygen").c; */
oxygen => frm("note").to(recbu, P_Set).c;

/// INDICATORS

MidiOut launchpadDeviceOut;
launchpadDeviceOut.open(MIDI_OUT_LAUNCHPAD);

recbu
  => frm("hasData").c
  => mk(TrigValue, 0).c
  => mk(NoteOut, launchpadDeviceOut, 0, false).c
;



recbu
  => frm("recording").c
  => mk(TrigValue, 16).c
  => mk(NoteOut, launchpadDeviceOut, 0, false).c
;





Runner.setPlaying(1);
Util.runForever();
