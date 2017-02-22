
include(macros.m4)


genHandler(TrigHandler, P_Trigger,
  HANDLE{
    buf[size-1] @=> IntRef curVal;
    if(curVal != null){
      // <<<"Spitting out: "+curVal.i>>>;
      parent.send(P_Trigger, curVal.i);
    }
    for(size-1=>int i;i>0;i--){
      buf[i-1] @=> buf[i];
    }
    IntRef.make(v) @=> buf[0];
    // <<<"Adding: "+buf[0].i>>>;
  },
  IntRef buf[];
  int size;
)


public class Buffer extends Moduck{
  fun static Buffer make(int size){
    Buffer ret;
    IntRef buf[size];
    for(0=>int i;i<size;i++){
      null @=> buf[i];
    }
    OUT(P_Trigger);
    IN(TrigHandler,(buf, size));
    return ret;
  }
}
