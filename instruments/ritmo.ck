
fun ModuckP ritmo(ModuckP rhythms[]){
  Util.concatStrings([
      [P_Clock]
      ,Util.numberedStrings("", Util.range(0, rhythms.size()))
  ])
  @=> string rootTags[];

  def(root, mk(Repeater, rootTags))
  def(out, mk(Repeater, P_Trigger));
  for(0=>int i;i<rhythms.size();++i){
    def(block, mk(Blocker));
    root
      .b(block.fromTo(""+i, P_Gate))
      .b(rhythms[i].fromTo(""+i, P_Reset))
    ;
    root
      => block.fromTo(P_Clock, P_Trigger).c
      => rhythms[i].c
      => out.c
    ;
  }

  return mk(Wrapper, root, out);
}
