
include(macros.m4)

class BufStep{
  null => IntRef val;
  false => int hasValue;
}


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
    v @=> buf[0].val;
    true @=> buf[0].hasValue;
  },
  BufStep buf[];
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
    buf[size] @=> BufStep curVal;
    if(curVal.hasValue){
      parent.send(P_Trigger, curVal.val);
    }
    false @=> buf[0].hasValue;
  },
  BufStep buf[];
)


genHandler(ResetHandler, P_Reset,
  HANDLE{
    if(null != v){
      parent.getVal("size") @=> int size;
      if(size == 0){
        return;
      }
      if(buf.size() < size+1){
        buf.size(size+1);
      }
      for(0=>int i;i<size+1;i++){
        false @=> buf[i].hasValue;
      }
    }
  },
  BufStep buf[];
)


public class PulseDelay extends Moduck{
  fun static PulseDelay make(int size){
    PulseDelay ret;
    BufStep buf[size];
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
