fun ModuckP multiRouter(ModuckP src, string tags[], ModuckP dests[]){
  return multiRouter(src, tags, dests, true);
}


fun ModuckP multiRouter(ModuckP src, string tags[], ModuckP dests[], int outOnChange){
  def(indexChooser, mk(Repeater));
  for(0=>int tagInd;tagInd<tags.size();++tagInd){
    tags[tagInd] @=> string tag;
    def(router, mk(Router, 0, outOnChange));

    indexChooser => router.to("index").c;
    src => frm(tag).c => router.c; 
    for(0=>int dstInd;dstInd<dests.size();++dstInd){
      dests[dstInd] @=> ModuckP dst;
      router => frm(dstInd).c => dst.to(tag).c;
    }

  }
  return indexChooser;
}
