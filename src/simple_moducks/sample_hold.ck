
include(moduck_macros.m4)


class Shared{
  MayInt val;
}

genHandler(TrigHandler, P_Trigger, 
  Shred @ shred;

  0 => int curInd;

  fun void doWait(int startInd){
    parent.getVal("holdTime")::samp => now;
    if(curInd == startInd){
      parent.send(P_Trigger, null);
    }
  }


  IntRef tmpRef;

  HANDLE{
    if(null != v){
      if(!shared.val.valid){
        parent.send(P_Trigger, null);
      } else {
        shared.val.i => tmpRef.i;
        parent.send(P_Trigger, tmpRef);
        if(!parent.getVal("forever")){
          curInd + 1 => curInd;
          if(curInd > 999999){
            0 => curInd;
          }
          spork ~ doWait(curInd) @=>  shred;
        }
      }
    }
  },
  Shared shared;
)


genHandler(SetHandler, P_Set, 
  HANDLE{
    if(v == null){
      shared.val.clear();
    }else{
      shared.val.set(v.i);
    }
    if(parent.getVal("triggerOnSet")){
      parent.send(P_Trigger, v);
    }
  },
  Shared shared;
)


public class SampleHold extends Moduck{
  Shared shared;

  fun IntRef get(){
    if(shared.val.valid){
      return IntRef.make(shared.val.i);
    }else{
      return null;
    }
  }

  maker(SampleHold, dur holdTime){
    SampleHold ret;
    OUT(P_Trigger);
    IN(TrigHandler, (ret.shared));
    IN(SetHandler, (ret.shared));
    ret.addVal("holdTime", Util.toSamples(holdTime));
    ret.addVal("forever", false);
    ret.addVal("triggerOnSet", false);
    return ret;
  }

  fun static SampleHold make(){
    make(0::ms) @=> SampleHold ret;
    samp =>  now;
    ret.setVal("forever", true);
    return ret;
  }
}
