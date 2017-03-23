

fun ModuckP ritmo(ModuckP rhythms[]){
  Util.concatStrings([
      [P_Clock]
      ,Util.numberedStrings("in", Util.range(0, rhythms.size()))
  ])
  @=> string rootTags[];

  def(root, mk(Repeater, rootTags))
  def(out, mk(Repeater, P_Trigger));
  for(0=>int i;i<rhythms.size();++i){
    <<<i>>>;
  }

  return mk(Wrapper, root, out);
}
