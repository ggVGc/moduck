include(macros.m4)
include(song_macros.m4)

define(LATENCY_COMPENSATION, 4)

public class RecBuf{
  maker(Moduck, int quantization){
    def(in, mk(Repeater, [
      P_Clock
      ,P_Set
      ,P_ClearAll
      ,P_Clear
      ,P_Toggle
    ]));

    def(out, mk(Repeater, [
      P_Trigger
      ,P_Recording
      ,P_Playing
      ,P_Looped
      ,"hasData"
    ]));

    def(buf, mk(Buffer));
    def(recWaiter, mk(OnceTrigger));
    def(recBlocker, mk(Blocker));
    def(recToggler, mk(Toggler, false));
    def(recStopDiv, mk(PulseDiv, quantization).set("offset", LATENCY_COMPENSATION));
    def(counter, mk(Counter));
    def(restartTimer, mk(PulseDiv, quantization));
    def(playBlocker, mk(Blocker));
    def(playToggler, mk(Toggler, false));
    def(clock, in => frm(P_Clock).c);
    def(toggleRec, mk(Repeater));
    def(lastSetVal, mk(Value, null));
    def(restartBuf, mk(Value, 0) => buf.to(P_GoTo).c);

    restartBuf
      => frm(recv(P_Trigger)).c
      => out.to(P_Looped).when(out, "hasData").c;

    in => frm(P_Set).c => lastSetVal.to(P_Set).c;

    playBlocker => out.fromTo(recv(P_Gate), P_Playing).c;

    in
      => frm(P_Toggle).c
      => iff(out, "hasData")
          .then( toggleRec.when(out, P_Recording) )
          .els( toggleRec ).c;


    playToggler
      .b(playBlocker.to(P_Gate))
      .b(frm(recv(P_Toggle)).to(restartBuf))
      .b(frm(recv(P_Toggle)).to(restartTimer, P_Reset));

    def(onBeginRec, recToggler => MBUtil.onlyHigh().c)
    def(onEndRec, recToggler => MBUtil.onlyLow().c => mk(Inverter).c);

    clock
      => restartTimer.whenNot(out, P_Recording).c
      => restartBuf.c;

    in => buf.listen([P_Clear, P_ClearAll]).c;
    clock => buf.to(P_Clock).c;

    (in => frm(P_ClearAll).c)
      .b(playToggler.to(P_Toggle).when(out, P_Playing))
      .b( recWaiter.to(P_Clear) );

    buf 
      => frm(recv(P_Clock)).c
      => mk(PulseDiv, quantization)
          .hook(recBlocker.fromTo(recv(P_Gate), P_Reset))
          .when(out, P_Recording).c
      => counter.c;

    // Queue a rec toggle
    toggleRec
      .b(recWaiter.to(P_Set))
      .b(playToggler.to(P_Toggle).whenNot(out, P_Playing));


    out
      => frm(P_Playing).c
      => MBUtil.onlyLow().c
      => out.to(P_Trigger).c;

    // Trigger rec waiter from input when not recording
    in
      => frm(P_Set).c
      => recWaiter.whenNot(out, P_Recording).c;

    // Trigger rec toggle from Clock, every recStopDiv division
    // when not recording
    clock
      => recStopDiv.when(out, P_Recording).c
      => recWaiter.c;

    // Trigger rec toggle from waiter
    recWaiter => recToggler.to(P_Toggle).c;

    def(divisorVal, mk(Value, 0));
    counter
      => mk(Bigger, 0).from("count").c
      => mk(Mul, quantization).c
      => divisorVal.to(P_Set).c;

    onEndRec
      .b( mk(Printer, "End rec"))
      .b(divisorVal => restartTimer.to("divisor").c)
      .b(mk(Delay, samp) => restartTimer.to(P_Reset).c);
    
    onBeginRec
      .b( mk(Printer, "Begin rec"))
      .b(recStopDiv.to(P_Reset))
      .b(counter.to(P_Reset))
      .b(recBlocker.to(P_Gate))
      .b(mk(Repeater).whenNot(out, "hasData")
          .b(restartBuf)
          .b(lastSetVal => buf.to(P_Set).c)
      );

    recToggler => recBlocker.to(P_Gate).c;

    in
      => frm(P_Set).c
      => recBlocker.c
      => buf.to(P_Set).c;

    recBlocker
      => frm(recv(P_Gate)).c
      => out.to(P_Recording).c;


    buf => out.listen("hasData").c;
    buf
      => frm(P_Trigger).to(playBlocker).c
      => out.c;


    samp => now;
    out.doHandle( P_Recording, null);
    out.doHandle("hasData",null);

    return mk(Wrapper, in, out);
  }
}
