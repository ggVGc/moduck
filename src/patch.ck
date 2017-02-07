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

  fun static Moduck connect(Moduck src, string srcEventName, Moduck target, string targetEventName){
    if(src.outKeys.size() == 0){
      <<<"Error: No source outputs:"+src>>>;
    }
    if(srcEventName == null){
      src.outKeys[0] => srcEventName;
    }
    if(src.outs[srcEventName] == null){
      <<<"Error: Invalid source event: "+srcEventName+" - "+src>>>;
    }

    if(target.handlerKeys.size() == 0){
      <<<"Error: No target inputs:"+target>>>;
    }
    if(targetEventName == null){
      target.handlerKeys[0] => targetEventName;
    }
    if(target.handlers[targetEventName] == null){
      <<<"Error: Invalid target event: "+targetEventName+" - "+target>>>;
    }
    /* <<<"Connecting "+src+"<>"+srcEventName+" to "+target+"<>"+targetEventName>>>; */
    spork ~ connectLoop(src, srcEventName, target, targetEventName);
    return Wrapper.make(src, target);
  }


  fun static Moduck connVal(Moduck src, string srcEventName, Moduck target, string key){
    if(src.outKeys.size() == 0){
      <<<"Error: No source outputs:"+src>>>;
    }
    if(srcEventName == null){
      src.outKeys[0] => srcEventName;
    }
    spork ~ connectValLoop(src, srcEventName, target, key);
    return Wrapper.make(src, target);
  }




  fun static Moduck chain(Moduck first, ChainData rest[]){
    first @=> Moduck h;
    for(0 => int i; i<rest.size(); i++){
      rest[i] @=> ChainData d;
      if(d.type == 1){
        connect(h, d.srcTag, d.target, d.targetTag) @=> h;
      }else{
        connVal(h, d.srcTag, d.target, d.targetTag) @=> h;
      }
    }
    return Wrapper.make(first, h);
  }

  fun static Moduck connectMulti(Moduck src, ChainData targets[]){
    Repeater.make() @=> Repeater out;
    for(0 => int i; i<targets.size(); i++){
      targets[i] @=> ChainData d;
      if(d.type == 1){
        connect(src, d.srcTag, d.target, d.targetTag);
        connect(d.target, d.targetTag, out, Pulse.Trigger());
      }else{
        connVal(src, d.srcTag, d.target, d.targetTag);
      }
    }

    return src;
  }
}
