
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
          recBuf.to(toggl(P_Play)
        )
    ).c;


  def(out, mk(Repeater));

  // Indicators
  def(trigOut, mk(Prio) => out.c);
  def(trigCol, iff(recBuf, P_Recording).then(LP.red2()).els(LP.yellow()));
  recBuf
    .b("hasData", LP.green() => trigOut.to(0).c)
    .b(P_Playing, LP.orange() => trigOut.to(1).c)
    .b(P_Recording, LP.red() => trigOut.to(2).c)
    .b(P_Trigger, trigCol => trigOut.to(3).c)
  ;

  return mk(Wrapper, in, out);
}
