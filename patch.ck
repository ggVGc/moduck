



public class Patch{
  // msg defaults to src tag if passed as null
  fun static void connectLoop(Moduck src, string srcEventName, Moduck target, string msg){
    while(true){
      src.out => now;
      true => int doHandle;
      if(srcEventName != null && srcEventName != src.out.tag){
        false => doHandle;
        /* <<<"Invalid source event: "+srcEventName+" - "+src>>>; */
      }
      if(msg == null){
        src.out.tag => msg;
      }
      if(doHandle){
        null @=> target.out.tag;
        if(!target.handle(msg, src.out.val)){
          <<<"Invalid event: "+msg+" - "+target>>>;
        }
        if(target.out.tag == null){
          src.out.tag => target.out.tag;
        }
      }
    }
  }


  fun static void connectValLoop(Moduck src, string srcEventName, Moduck target, string valueName){
    while(true){
      src.out => now;
      if(srcEventName != null && srcEventName != "" && srcEventName != src.out.tag){
        <<<"Invalid source event: "+srcEventName+" - "+src>>>;
      }
      if(target.values[valueName] == null){
        <<<"Invalid value: "+valueName+" - "+target>>>;
      }
      IntRef.make(src.out.val) @=> target.values[valueName];
    }
  }

  fun static Moduck connect(Moduck src, string srcEventName, Moduck target, string msg){
    spork ~ connectLoop(src, srcEventName, target, msg);
    return Wrapper.make(src, target);
  }


  fun static Moduck connVal(Moduck src, string srcEventName, Moduck target, string msg){
    spork ~ connectValLoop(src, srcEventName, target, msg);
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
    return h;
  }

  fun static Moduck connectMulti(Moduck src, ChainData targets[]){
    Repeater out;
    for(0 => int i; i<targets.size(); i++){
      targets[i] @=> ChainData d;
      if(d.type == 1){
        connect(src, d.srcTag, d.target, d.targetTag);
      }else{
        connVal(src, d.srcTag, d.target, d.targetTag);
      }
      connect(d.target, null, out, null);
    }

    return Wrapper.make(src, out);
  }
}
