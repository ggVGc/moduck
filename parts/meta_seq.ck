fun ModuckP metaSeq(string pattern, int stepSize, int totalLen, ModuckP variations[]){
  return metaSeq(pattern, stepSize, totalLen, MUtil.castModuckList(variations));
}


fun ModuckP metaSeq(string pattern, int stepSize, int totalLen, Moduck variations[]){
  def(divider, seqDiv(pattern, stepSize, totalLen))
  def(router, mk(Router, 0))



  divider => router.to("index").c;

  def(routerOut, mk(Repeater, [P_Trigger, P_Looped]))
  for(0 => int i; i<variations.size(); i++){
    def(v, variations[i]);
    router => v.from(""+i).c;
    v => routerOut.c;
  }

  def(out, mk(Wrapper, router, routerOut))


  def(root, mk(Repeater, [P_Trigger, P_Clock, P_Reset]))

  divider => routerOut.listen(P_Looped).c;

  root.multi([
    (mk(Delay, samp) => router.c).from(P_Trigger) // Delay triggers, if clock or reset happens in same frame
    ,router.from(P_Reset).to(P_Reset)
    ,divider.from(P_Reset).to(P_Reset)
    ,divider.from(P_Clock).to(P_Trigger)
  ]);


  /*
    root => router.from(P_Trigger).c;
    root => divider.from(P_Reset).to(P_Reset).c;
    root => divider.from(P_Step).to(P_Trigger).c;
   */
  

  return mk(Wrapper, root, out);
}



fun ModuckP metaSeq(string pattern, int stepSize, int totalLen, ModuckP variations[]){
  return metaSeq(pattern, stepSize, totalLen, MUtil.castModuckList(variations));
}


/*
  fun ModuckP metaSeq(string pattern, int stepSize, int totalLen, Moduck variations[]){
    def(root, mk(Repeater, [P_Trigger, P_Clock, P_Reset]))
  
    def(divider, seqDiv(pattern, stepSize, totalLen))
    def(router, mk(Router, 0))
  
    divider => router.to("index").c;
  
    def(routerOut, mk(Repeater, [P_Trigger, P_Looped]))
    def(out, mk(Wrapper, router, routerOut))
  
    def(resetGate, mk(Router, 0))
  
  
    root.setVal("resetOnLoop", false);
    // root => resetGate.fromTo(recv("resetOnLoop"), "index").c;
    root => mk(Printer, "RESSSS").from(recv("resetOnLoop")).c => resetGate.to("index").c;
    samp => now;
    resetGate => mk(Printer, "IND").from(recv("index")).c;
    root.setVal("resetOnLoop", false);
    def(resetter, mk(Repeater))
    resetGate => resetter.from("1").c;
    resetter => mkc(Printer, "Reset Out");
  
    divider => mk(Printer, "div looped").c;
  
    for(0 => int i; i<variations.size(); i++){
      def(v, variations[i]);
      router => v.from(""+i).c;
      v => routerOut.c;
      resetter => mkc(Printer, "Child reset") => v.to(P_Reset).c;
    }
  
  
  
  
    divider => routerOut.listen(P_Looped).c;
  
    root.multi([
      (mk(Delay, samp) => router.c).from(P_Trigger) // Delay triggers, if clock or reset happens in same frame
      ,router.from(P_Reset).to(P_Reset)
      ,divider.from(P_Reset).to(P_Reset)
      ,divider.from(P_Clock).to(P_Trigger)
    ]);
  
  
    
  
    samp => now;
    root.set("resetOnLoop", true);
    return mk(Wrapper, root, out);
  }
 */
