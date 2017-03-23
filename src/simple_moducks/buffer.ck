
include(macros.m4)


genHandler(TrigHandler, P_Trigger,
  HANDLE{
    if(null != v){
      parent.getVal("size") @=> int size;
      if(size == 0){
        parent.send(P_Trigger, v);
        return;
      }
      if(buf.size() < size){
        buf.size(size);
      }
      buf[size-1] @=> IntRef curVal;
      if(curVal != null){
        // <<<"Spitting out: "+curVal.i>>>;
        parent.send(P_Trigger, curVal);
      }
      for(size-1=>int i;i>0;i--){
        buf[i-1] @=> buf[i];
      }
      v @=> buf[0];
      // <<<"Adding: "+buf[0].i>>>;
    }
  },
  IntRef buf[];
)


genHandler(ResetHandler, P_Reset,
  HANDLE{
    if(null != v){
      parent.getVal("size") @=> int size;
      if(size == 0){
        return;
      }
      if(buf.size() < size){
        buf.size(size);
      }
      for(0=>int i;i<size;i++){
        null @=> buf[i];
      }
    }
  },
  IntRef buf[];
)

public class Buffer extends Moduck{
  fun static Buffer make(int size){
    Buffer ret;
    IntRef buf[size];
    for(0=>int i;i<size;i++){
      null @=> buf[i];
    }
    OUT(P_Trigger);
    IN(TrigHandler,(buf));
    IN(ResetHandler,(buf));
    ret.addVal("size", size);
    return ret;
  }

  fun static Moduck[] many(int count, int size){
    Moduck ret[count];
    for(0=>int x;x<count;++x){
      make(size) @=> ret[x];
    }
    return ret;
  }
}
