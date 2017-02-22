


fun ModuckP metaSeq(string pattern, int stepSize, int totalLen, Moduck variations[]){
  def(root, mk(Repeater, [P_Trigger, P_Clock, P_Reset]))

  def(divider, seqDiv(pattern, stepSize, totalLen))
  def(router, mk(Router, 0))

  divider => router.to("index").c;

  def(routerOut, mk(Repeater, [P_Trigger, P_Looped]))
  def(out, mk(Wrapper, router, routerOut))

  def(resetGate, mk(Router, 0))


  root.addVal("resetOnLoop", false);
  root => resetGate.fromTo(recv("resetOnLoop"), "index").c;
  root.setVal("resetOnLoop", false);
  def(resetter, mk(Repeater))
  resetGate => resetter.from("1").c;

  divider => resetGate.from(P_Looped).c;

  for(0 => int i; i<variations.size(); i++){
    def(v, variations[i]);
    router => v.from(""+i).c;
    v => routerOut.c;
    resetter => v.to(P_Reset).c;
  }

  divider => routerOut.listen(P_Looped).c;

  root.multi([
    (mk(Delay, samp) => router.c).from(P_Trigger) // Delay triggers, if clock or reset happens in same frame
    ,router.from(P_Reset).to(P_Reset)
    ,divider.from(P_Reset).to(P_Reset)
    ,divider.from(P_Clock).to(P_Trigger)
  ]);

  return mk(Wrapper, root, out);
}


fun ModuckP metaSeq(string pattern, int stepSize, int totalLen, ModuckP variations[]){
  return metaSeq(pattern, stepSize, totalLen, MUtil.castModuckList(variations));
}
