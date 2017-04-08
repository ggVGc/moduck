include(macros.m4)
include(song_macros.m4)

public class RecBuf{
  maker(Moduck, int quantization){
    def(in, mk(Repeater, [P_Clock, P_Set, P_ClearAll, P_Clear, "toggleRec", "overdubToggle"]));
    def(out, mk(Repeater, [P_Trigger, "recording", "hasData"]));

    def(buf, mk(Buffer));
    def(recWaiter, mk(OnceTrigger));
    def(recBlocker, mk(Blocker));
    def(recToggler, mk(Toggler, false));
    def(recStopDiv, mk(PulseDiv, quantization));
    def(counter, mk(Counter));
    def(restartDiv, mk(PulseDiv, quantization));

    def(onBeginRec, recToggler => MBUtil.onlyHigh().c)
    def(onEndRec, recToggler => MBUtil.onlyLow().c => mk(Inverter).c);

    def(restartBuf, mk(Value, 0)
        => buf.to(P_GoTo).c);

    in
      => frm(P_Clock).c
      => restartDiv.whenNot(out, "recording").c
      => restartBuf.c;


    in => buf.listen([P_Clock, P_Clear, P_ClearAll]).c;

    buf 
      => frm(recv(P_Clock)).c
      => mk(PulseDiv, quantization)
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
      => mk(Mul, quantization).c
      => divisorVal.to(P_Set).c;

    onEndRec
      .b(divisorVal => restartDiv.to("divisor").c)
      .b(mk(Delay, samp) => restartDiv.to(P_Reset).c)
    ;
    
    onBeginRec
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
