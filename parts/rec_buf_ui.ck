

fun ModuckP recBufUI(ModuckP recBuf){
  def(in, mk(Repeater, [
    P_Trigger
    ,P_ClearAll
  ]));

  in
    => frm(P_Trigger).c
      => iff(in, P_ClearAll).then(
          recBuf.to(P_ClearAll))
      .els(
          recBuf.to(P_Toggle)
      ).c;


  def(out, mk(Repeater));

  // Indicators
  def(trigOut, mk(Prio) => out.c);

  MUtil.sigEq(recBuf, "state", RecBuf.Playing) => LP.green().c => trigOut.to(1).c;
  MUtil.sigEq(recBuf, "state", RecBuf.Recording) => LP.red().c => trigOut.to(2).c;
  MUtil.sigEq(recBuf, "state", RecBuf.RecOnArmed) => LP.red().c => trigOut.to(3).c;
  MUtil.sigEq(recBuf, "state", RecBuf.RecOffArmed) => LP.red().c => trigOut.to(4).c;
  recBuf
    .b("hasData", LP.orange() => trigOut.to(0).c)
    .b(P_Trigger, LP.orange() => trigOut.to(5).c)
    /* .b(P_Looped, LP.green2() => mk(SampleHold, 200::ms).to(P_Set).to(P_Trigger).c => trigOut.to(4).c); */
    .b(P_Looped, LP.red() => mk(SampleHold, 150::ms).to(P_Set).to(P_Trigger).c => trigOut.to(6).c);

  return mk(Wrapper, in, out);
}

