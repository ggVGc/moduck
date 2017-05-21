fun ModuckP togglingOuts(int outCount){
  [P_Trigger] @=> string rootTags[];
  string outTags[0];
  for(0=>int i;i<outCount;++i){
    rootTags << "toggleOut"+i;
    outTags << "outActive"+i;
    outTags << ""+i;
  }
  def(root, mk(Repeater, rootTags));
  def(out, mk(Repeater, outTags));

  ModuckP outBlockers[outCount];
  for(0=>int i;i<outCount;++i){
    def(blocker, mk(Blocker, true));
    def(toggler, mk(Toggler, false));

    blocker @=> outBlockers[i];

    root => frm("toggleOut"+i).to(toggler, P_Toggle).c;

    toggler 
      .b(blocker.to(P_Gate))
      .b(out.to("outActive"+i))
    ;
    root
      => frm(P_Trigger).c
      => blocker.c
      => out.to(i).c
    ;
  }

  return mk(Wrapper, root, out);
}
