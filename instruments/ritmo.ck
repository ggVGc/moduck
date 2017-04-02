

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


fun ModuckP combinedChain(ModuckP rhythms[], ModuckP root, ModuckP out, string extraTags[], ModuckP _ /* holdBlocker */){
  for(0=>int i;i<rhythms.size();++i){
    rhythms[i] @=> ModuckP rh;
    def(block, mk(Blocker));
    root => mk(Repeater).from(""+i).c => block.to(P_Gate).c;
    /* 
       .b(MUtil.onlyHigh() => block.to(P_Gate).c)
       .b(MUtil.onlyLow() => holdBlocker.c => block.to(P_Gate).c)
     ;
     */
    if(rh.hasHandler(P_Reset)){
      root => rh.listen(P_Reset).c;
    }
    root
      => rh.c
      => block.to(P_Trigger).c
      => out.c
    ;

    block => out.fromTo(recv(P_Gate), "active_"+i).c;

    for(0=>int tagInd;tagInd<extraTags.size();++tagInd){
      extraTags[tagInd] @=> string tag;
      def(tagBlocker, mk(Blocker));
      root => tagBlocker.fromTo(""+i, P_Gate).c;
      root
        => tagBlocker.fromTo("active_"+tag, P_Trigger).c
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
    [P_Clock, P_Reset,P_Hold]
    ,extraTags
    ,Util.prefixStrings("active_", extraTags)
    ,Util.numberedStrings("", Util.range(0, rhythms.size()-1))
  ])
    @=> string rootTags[];

  def(root, mk(Repeater, rootTags))
  def(out, mk(Repeater,
      Util.concatStrings([
        [P_Trigger],
        Util.numberedStrings("active_", Util.range(0, rhythms.size()-1))
      ])));

  for(0=>int rhythmInd;rhythmInd<rhythms.size();++rhythmInd){
    rhythms[rhythmInd] @=> ModuckP rh;
    for(0=>int tagInd;tagInd<extraTags.size();++tagInd){
      extraTags[tagInd] @=> string tag;
      root => rh.listen(tag).c;
    }
  }

  def(holdBlocker, mk(Blocker));
  holdBlocker => mk(Printer, "GATE").from(recv(P_Gate)).c;
  root => holdBlocker.fromTo(P_Hold, P_Gate).c;
  holdBlocker.doHandle(P_Gate, IntRef.make(0));

  if(individualMode){
    individualsChain(rhythms, root, out, extraTags);
  }else{
    combinedChain(rhythms, root, out, extraTags, holdBlocker);
  }


  return mk(Wrapper, root, out);
}
