

fun ModuckP individualsChain(ModuckP rhythms[], ModuckP root){
  def(out, mk(Repeater, P_Trigger));
  for(0=>int i;i<rhythms.size();++i){
    def(block, mk(Blocker));
    root
      .b(block.fromTo(""+i, P_Gate))
    ;
    root
      => block.fromTo(P_Clock, P_Trigger).c
      => rhythms[i].c
      => out.c
    ;
    if(rhythms[i].hasHandler(P_Reset)){
      root => rhythms[i].listen(P_Reset).c;
      root => rhythms[i].fromTo(""+i, P_Reset).c;
    }
  }
  return out;
}


fun ModuckP combinedChain(ModuckP rhythms[], ModuckP root){
  def(out, mk(Repeater, P_Trigger));
  for(0=>int i;i<rhythms.size();++i){
    def(block, mk(Blocker));
    root
      .b(block.fromTo(""+i, P_Gate))
    ;
    if(rhythms[i].hasHandler(P_Reset)){
      root => rhythms[i].listen(P_Reset).c;
    }
    root
      => rhythms[i].c
      => block.to(P_Trigger).c
      => out.c
    ;
  }
  return out;
}

fun ModuckP ritmo(ModuckP rhythms[]){
  return ritmo(false, rhythms);
}

fun ModuckP ritmo(int individualMode, ModuckP rhythms[]){
  Util.concatStrings([
      [P_Clock, P_Reset]
      ,Util.numberedStrings("", Util.range(0, rhythms.size()))
  ])
    @=> string rootTags[];

  def(root, mk(Repeater, rootTags))


  ModuckP out;

  if(individualMode){
    individualsChain(rhythms, root) @=> out;
  }else{
    combinedChain(rhythms, root) @=> out;
  }

  return mk(Wrapper, root, out);



}
