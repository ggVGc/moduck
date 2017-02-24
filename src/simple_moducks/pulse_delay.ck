
include(macros.m4)


genHandler(TrigHandler, P_Trigger,
  HANDLE{
    parent.getVal("size") @=> int size;
    if(size == 0){
      parent.send(P_Trigger, v);
      return;
    }
    if(buf.size() < size+1){
      buf.size(size+1);
    }
    IntRef.make(v) @=> buf[0];
  },
  IntRef buf[];
)



genHandler(ClockHandler, P_Clock,
  HANDLE{
    parent.getVal("size") @=> int size;
    if(size == 0){
      return;
    }
    if(buf.size() < size+1){
      buf.size(size+1);
    }
    for(size=>int i;i>0;i--){
      buf[i-1] @=> buf[i];
    }
    buf[size] @=> IntRef curVal;
    if(curVal != null){
      parent.send(P_Trigger, curVal.i);
    }
    null @=> buf[0];
  },
  IntRef buf[];
)


genHandler(ResetHandler, P_Reset,
  HANDLE{
    parent.getVal("size") @=> int size;
    if(size == 0){
      return;
    }
    if(buf.size() < size+1){
      buf.size(size+1);
    }
    for(0=>int i;i<size+1;i++){
      null @=> buf[i];
    }
  },
  IntRef buf[];
)

public class PulseDelay extends Moduck{
  fun static PulseDelay make(int size){
    PulseDelay ret;
    IntRef buf[size];
    for(0=>int i;i<size;i++){
      null @=> buf[i];
    }
    OUT(P_Trigger);
    IN(TrigHandler,(buf));
    IN(ResetHandler,(buf));
    IN(ClockHandler,(buf));
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
