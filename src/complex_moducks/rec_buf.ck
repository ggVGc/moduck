include(macros.m4)
include(song_macros.m4)

public class RecBuf{
  maker(Moduck, int quantization){
    def(in, mk(Repeater, [
      P_Clock
      ,P_Set
      ,P_ClearAll
      ,P_Clear
      ,toggl(P_Rec)
      ,toggl(P_Play)
    ]));

    def(out, mk(Repeater, [
      P_Trigger
      ,P_Recording
      ,P_Playing
      ,"hasData"
    ]));

    def(buf, mk(Buffer));
    def(recWaiter, mk(OnceTrigger));
    def(recBlocker, mk(Blocker));
    def(recToggler, mk(Toggler, false));
    def(recStopDiv, mk(PulseDiv, quantization));
    def(counter, mk(Counter));
    def(restartDiv, mk(PulseDiv, quantization));
    def(playBlocker, mk(Blocker));
    def(playToggler, mk(Toggler, false));
    def(clock, in => frm(P_Clock).c);

    def(restartBuf, mk(Value, 0) => buf.to(P_GoTo).c);

    playBlocker => out.fromTo(recv(P_Gate), P_Playing).c;

    in
      => frm(toggl(P_Play)).c
      => mk(Repeater).when(out, "hasData").c
      => iff(out, P_Recording)
          .then(in.to(toggl(P_Rec)))
          .els(playToggler.to(P_Toggle)).c;


    playToggler
      .b(playBlocker.to(P_Gate))
      .b(frm(recv(P_Toggle)).to(restartBuf))
      .b(frm(recv(P_Toggle)).to(restartDiv, P_Reset))
    ;

    def(onBeginRec, recToggler => MBUtil.onlyHigh().c)
    def(onEndRec, recToggler => MBUtil.onlyLow().c => mk(Inverter).c);



    clock
      => restartDiv.whenNot(out, P_Recording).c
      => restartBuf.c;


    in => buf.listen([P_Clear, P_ClearAll]).c;
    clock => buf.to(P_Clock).c;

    in
      => frm(P_ClearAll).c
      => playToggler.to(P_Toggle).when(out, P_Playing).c;

    buf 
      => frm(recv(P_Clock)).c
      => mk(PulseDiv, quantization)
          .hook(recBlocker.fromTo(recv(P_Gate), P_Reset))
          .when(out, P_Recording).c
      => counter.c
    ;

    // Queue a rec toggle
    (in => frm(toggl(P_Rec)).c)
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
      => recBlocker.c      // Otherwise we lose the first note
      => buf.to(P_Set).c;

    recBlocker
      => frm(recv(P_Gate)).c
      => out.to(P_Recording).c
    ;

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
