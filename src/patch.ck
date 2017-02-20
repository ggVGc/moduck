include(pulses.m4)

public class Patch{
  fun static void connectLoop(Moduck src, string srcEventName, Moduck target, string targetEventName){
    while(true){
      src.outs[srcEventName] @=> VEvent ev;
      if(ev == null){
        <<<"Null event from "+src+":"+srcEventName>>>;
      }
      ev => now;
      target.doHandle(targetEventName, ev.val);
    }
  }


  fun static void connectValLoop(Moduck src, string srcEventName, Moduck target, string valueName){
    while(true){
      src.outs[srcEventName] @=> VEvent ev;
      ev => now;
       if(target.values[valueName] == null){
         <<<"Invalid value: "+valueName+" - "+target>>>;
       }
       target.setVal(valueName, ev.val);
    }
  }


  fun static Moduck connect(Moduck src, Moduck target){
    return connect(src, null, target, null);
  }


  fun static Moduck connect(Moduck src, string srcTag, Moduck target, string targetTag){
    return connect(src, [srcTag], target, [targetTag]);
  }


  fun static Moduck connect(Moduck src, string srcEventNames[], Moduck target, string targetEventNames[]){
    if(srcEventNames == null){
      [P_Default] @=> srcEventNames;
    }
    if(targetEventNames == null){
      [P_Default] @=> targetEventNames;
    }
    if(src.outKeys.size() == 0){
      <<<"Error: No source outputs:"+src>>>;
    }

    if(target.handlerKeys.size() == 0){
      <<<"Error: No target inputs:"+target>>>;
    }

    for(0 => int i; i<srcEventNames.size(); i++){
      srcEventNames[i] => string srcTag;
      string dstTag;
      if(i < targetEventNames.size()){
        targetEventNames[i] => dstTag;
      }else{
        P_Default @=> dstTag;
      }

      if(srcTag == P_Default){
        src.outKeys[0] => srcTag;
      }
      if(dstTag == P_Default ){
        target.handlerKeys[0] => dstTag;
      }

      if(src.outs[srcTag] == null){
        <<<"Error: Invalid source event: "+srcTag+" - "+src>>>;
      }

      <<<"Connecting "+src+"<>"+srcTag+" to "+target+"<>"+dstTag>>>;
      if(target.hasValueKey(dstTag)){
        spork ~ connectValLoop(src, srcTag, target, dstTag);
      }else{
        if(target.handlers[dstTag] == null){
          <<<"Error: Invalid target event: "+dstTag+" - "+target>>>;
        }
        spork ~ connectLoop(src, srcTag, target, dstTag);
      }
    }
    return Wrapper.make(src, target);
  }


  fun static Moduck chain(Moduck first, ChainData rest[]){
    first @=> Moduck h;
    for(0 => int i; i<rest.size(); i++){
      rest[i] @=> ChainData d;
      connect(h, d.srcTags, d.target, d.targetTags) @=> h;
    }
    return Wrapper.make(first, h);
  }

  fun static Moduck connectMulti(Moduck src, ChainData targets[]){
    Repeater.make() @=> Repeater out;
    for(0 => int i; i<targets.size(); i++){
      targets[i] @=> ChainData d;
      connect(src, d.srcTags, d.target, d.targetTags);
      // TODO: Combine into Repeater with all outputs available
      // implement using MUtil.combine
      connect(d.target, null, out, P_Trigger);
    }

    return Wrapper.make(src, out);
  }

  fun static Moduck thru(Moduck other){
    Repeater.make() @=> Repeater inp;
    Delay.make(samp) @=> Delay out;
    Patch.connectMulti(inp, [
      ChainData.make(null, other, null)
      ,ChainData.make(null, out, null)
    ]);
    return Wrapper.make(inp, out);
  }

}
