
include(moduck_macros.m4)

class BufStep{
  MayInt val;
  false => int hasValue;
}


fun void resizeBuf(BufStep buf[], int targetSize){
 buf.size() => int oldSize;
 if(oldSize < targetSize+1){
   buf.size(targetSize+1);
   for(oldSize => int i; i<targetSize+1; ++i){
     BufStep s;
     s @=> buf[i];
   }
 }
}

genHandler(TrigHandler, P_Trigger,
  HANDLE{
    parent.getVal("size") @=> int size;
    if(size == 0){
      parent.send(P_Trigger, v);
      return;
    }
    resizeBuf(buf, size);
    buf[0].val.setFromRef(v);
    true @=> buf[0].hasValue;
  },
  BufStep buf[];
)


genHandler(ClockHandler, P_Clock,

  IntRef tmpRef;

  HANDLE{
    parent.getVal("size") @=> int size;
    if(size == 0){
      return;
    }
    resizeBuf(buf, size);
    for(size=>int i;i>0;i--){
      buf[i-1] @=> BufStep prev;
      if(prev.val.valid){
        buf[i].val.set(prev.val.i);
      }else{
        buf[i].val.clear();
      }
      prev.hasValue => buf[i].hasValue;
    }
    buf[size] @=> BufStep curStep;
    if(curStep.hasValue){
      curStep.val.i => tmpRef.i;
      parent.send(P_Trigger, tmpRef);
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
      resizeBuf(buf, size);
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
    BufStep buf[0];
    resizeBuf(buf, size);
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
