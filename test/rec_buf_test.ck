include(song_macros.m4)
include(macros.m4)

class RecBuf{
  maker0(Moduck){
    def(in, mk(Repeater, [P_Clock, P_Set, P_ClearAll, P_Clear, "toggleRec", "overdubToggle"]));
    def(out, mk(Repeater, [P_Trigger, "recording", "hasData"]));

    def(buf, mk(Buffer));
    def(recWaiter, mk(OnceTrigger));
    def(recBlocker, mk(Blocker));
    def(recToggler, mk(Toggler, false));
    def(recStopDiv, mk(PulseDiv, Bar));
    def(counter, mk(Counter));
    def(restartDiv, mk(PulseDiv, Bar));

    def(onBeginRec, recToggler => MBUtil.onlyHigh().c)
    def(onEndRec, recToggler => MBUtil.onlyLow().c => mk(Inverter).c);

    def(restartBuf, mk(Value, 0)
        => mk(Printer, "restarting buf").c
        => buf.to(P_GoTo).c);

    in
      => frm(P_Clock).c
      => restartDiv.whenNot(out, "recording").c
      => restartBuf.c;

    counter => mk(Printer, "count").from("count").c;

    in => buf.listen([P_Clock, P_Clear, P_ClearAll]).c;

    buf 
      => frm(recv(P_Clock)).c
      => mk(PulseDiv, Bar)
          .hook(recBlocker.fromTo(recv(P_Gate), P_Reset))
          .when(out, "recording").c
      => counter.c
    ;

    // Queue a rec toggle
    in
      => frm("toggleRec").c
      => recWaiter.to(P_Set).c;


    // Trigger rec waiter from input when not recording
    in
      => frm(P_Set).c
      => recWaiter.whenNot(out, "recording").c;

    // Trigger rec toggle from Clock, every recStopDiv division
    // when not recording
    in
      => frm(P_Clock).c
      => recStopDiv.when(out, "recording").c
      => recWaiter.c;

    // Trigger rec toggle from waiter
    recWaiter => recToggler.to(P_Toggle).c;

    def(divisorVal, mk(Value, 0));
    counter
      => mk(Bigger, 0).from("count").c
      => mk(Add, -1).c
      => mk(Mul, Bar).c
      => divisorVal.to(P_Set).c;

    onEndRec
      .b(divisorVal
          => mk(Printer, "New Divisor").c
          => restartDiv.to("divisor").c
      )
      .b(
          mk(Printer, "On End Rec")
          => mk(Delay, samp).c => restartDiv.to(P_Reset).c
      )
    ;
    
    onBeginRec
      .b(mk(Printer, "Begin Rec"))
      .b(recStopDiv.to(P_Reset))
      .b(counter.to(P_Reset))
      .b(restartBuf.whenNot(out, "hasData"))
      .b(recBlocker.to(P_Gate))
    ;

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


/* recbu => frm("hasData").to(mk(Printer, "hasData")).c; */


launchpad => mk(Printer, "did").from("cc104").c;

fun ModuckP recBufUI(ModuckP recBuf){
  def(in, mk(Repeater, [
    P_Trigger
    ,"clearAllSwitch"
  ]));
  def(out, mk(Repeater));

  in => mk(Printer, "clearAllSwitch").from("clearAllSwitch").c;

  /* 
   (in=>frm(P_Trigger).c)
     .b(recBuf.to(P_ClearAll).when(in,"clearAllSwitch"))
     .b(recBuf.to("toggleRec").whenNot(in,"clearAllSwitch"))
   ;
   */

  in
    => frm(P_Trigger).c
    => iff(in,"clearAllSwitch")
      .then(recBuf.to(P_ClearAll))
      .els(recBuf.to("toggleRec")).c
  ;


  return mk(Wrapper, in, out);
}


MidiOut circuitDeviceOut;
<<<"Opening circuit out">>>;
circuitDeviceOut.open(MIDI_OUT_CIRCUIT);
def(circuit, mk(NoteOut, circuitDeviceOut, 0, false));


ModuckP bufs[0];
ModuckP uis[0];

for(0=>int i;i<4;++i){
  def(buf, mk(RecBuf));
  def(ui, recBufUI(buf));
  uis << ui;
  bufs << buf;
  launchpad => frm("note0").to(ui, "clearAllSwitch").c;
  launchpad => frm("note"+(16+i)).to(ui, P_Trigger).c;
  Runner.masterClock => buf.to(P_Clock).c;
  oxygen => frm("note").to(buf, P_Set).c;
  buf => circuit.c;
}

/// INDICATORS

MidiOut launchpadDeviceOut;
launchpadDeviceOut.open(MIDI_OUT_LAUNCHPAD);

/* 
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
 */




Runner.setPlaying(1);
Util.runForever();
