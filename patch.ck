
public class Patch{
  fun static void connectLoop(Handler src, string srcEventName, Handler target, string msg){
    while(true){
      src.out => now;
      if(srcEventName != null && srcEventName != "" && srcEventName != src.out.tag){
        <<<"Invalid source event: "+srcEventName+" - "+src>>>;
      }
      Util.strOrNull(msg) => msg;
      if(!target.handle(msg, src.out.val)){
        <<<"Invalid event: "+msg+" - "+target>>>;
      }
    }
  }


  fun static void connectValLoop(Handler src, string srcEventName, Handler target, string valueName){
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

  fun static Handler connect(Handler src, string srcEventName, Handler target, string msg){
    spork ~ connectLoop(src, srcEventName, target, msg);
    return target;
  }

  fun static Handler connVal(Handler src, string srcEventName, Handler target, string msg){
    spork ~ connectValLoop(src, srcEventName, target, msg);
    return target;
  }


  fun static Handler chain(Handler first, ChainData rest[]){
    first @=> Handler h;
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

  fun static void connectMulti(Handler src, ChainData targets[]){
    for(0 => int i; i<targets.size(); i++){
      targets[i] @=> ChainData d;
      if(d.type == 1){
        connect(src, d.srcTag, d.target, d.targetTag);
      }else{
        connVal(src, d.srcTag, d.target, d.targetTag);
      }
    }
  }
}
