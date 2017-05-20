
fun ModuckP multiSwitcher(ModuckP srcs[], string tags[], ModuckP dst){
  return multiSwitcher(false, srcs, tags, dst);
}

fun ModuckP multiSwitcher(int onlyOutOnNewIndex, ModuckP srcs[], string tags[], ModuckP dst){
  def(indexChooser, mk(Repeater));
  for(0=>int tagInd;tagInd<tags.size();++tagInd){
    tags[tagInd] @=> string tag;
    def(switcher, mk(Switcher, srcs.size(), 0, onlyOutOnNewIndex));
    indexChooser => switcher.to("index").c;
    switcher => dst.to(tag).c;
    for(0=>int srcInd;srcInd<srcs.size();++srcInd){
      10::ms => now;
      srcs[srcInd] @=> ModuckP src;
      src => frm(tag).c => switcher.to(srcInd).c;
    }
  }

  return indexChooser;
}
