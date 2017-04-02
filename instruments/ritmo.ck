

fun ModuckP individualsChain(ModuckP rhythms[], ModuckP root, ModuckP out, string extraTags[]){
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


fun ModuckP combinedChain(ModuckP rhythms[], ModuckP root, ModuckP out, string extraTags[]){
  for(0=>int i;i<rhythms.size();++i){
    rhythms[i] @=> ModuckP rh;
    def(block, mk(Blocker));
    root
      .b(block.fromTo(""+i, P_Gate))
    ;
    if(rh.hasHandler(P_Reset)){
      root => rh.listen(P_Reset).c;
    }
    root
      => rh.c
      => block.to(P_Trigger).c
      => out.c
    ;
    for(0=>int tagInd;tagInd<extraTags.size();++tagInd){
      extraTags[tagInd] @=> string tag;
      def(tagBlocker, mk(Blocker));
      root => tagBlocker.fromTo(""+i, P_Gate).c;
      root
        => tagBlocker.fromTo("selected_"+tag, P_Trigger).c
        => rh.to(tag).c
      ;
    }
  }
  return out;
}

fun ModuckP ritmo(ModuckP rhythms[]){
  string s[0];
  return ritmo(false, s, rhythms);
}


fun ModuckP ritmo(int individualMode, ModuckP rhythms[]){
  string s[0];
  return ritmo(individualMode, s, rhythms);
}

fun ModuckP ritmo(int individualMode, string extraTags[], ModuckP rhythms[]){
  Util.concatStrings([
    [P_Clock, P_Reset]
    ,extraTags
    ,Util.prefixStrings("selected_", extraTags)
    ,Util.numberedStrings("", Util.range(0, rhythms.size()-1))
  ])
    @=> string rootTags[];

  def(root, mk(Repeater, rootTags))
  def(out, mk(Repeater, [P_Trigger, "input"]));

  for(0=>int rhythmInd;rhythmInd<rhythms.size();++rhythmInd){
    rhythms[rhythmInd] @=> ModuckP rh;
    for(0=>int tagInd;tagInd<extraTags.size();++tagInd){
      extraTags[tagInd] @=> string tag;
      root => rh.listen(tag).c;
    }
  }

  if(individualMode){
    individualsChain(rhythms, root, out, extraTags);
  }else{
    combinedChain(rhythms, root, out, extraTags);
  }


  return mk(Wrapper, root, out);
}
