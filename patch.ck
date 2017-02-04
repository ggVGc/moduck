
public class Patch{
  fun static void connectLoop(Handler src, string srcEventName, Handler target, string msg){
    while(true){
      src.out => now;
      if(srcEventName != null && srcEventName != "" && srcEventName != src.out.tag){
        <<<"Invalid source event: "+srcEventName+" - "+src>>>;
      }
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
      Util.iref(src.out.val) @=> target.values[valueName];
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
}
