
include(macros.m4)
include(song_macros.m4)


class Shared{
  IntRef val;
}

genHandler(TrigHandler, P_Trigger, 
  Shred @ shred;
  IntRef lastShouldTrigger;

  fun void doWait(IntRef shouldTrigger){
    parent.getVal("holdTime")::samp => now;
    if(shouldTrigger.i){
      parent.send(P_Trigger, null);
    }
  }


  HANDLE{
    if(null != v){
      if(sharedVal.val == null){
        parent.send(P_Trigger, null);
      } else {
        if(null != shred){
          false => lastShouldTrigger.i;
          null @=> lastShouldTrigger;
          null @=> shred;
        }
        parent.send(P_Trigger, sharedVal.val);
        IntRef.make(true) @=> lastShouldTrigger;
        if(!parent.getVal("forever")){
          spork ~ doWait(lastShouldTrigger) @=> shred;
        }
      }
    }
  },
  Shared sharedVal;
)


genHandler(SetHandler, P_Set, 
  HANDLE{
    v @=> sharedVal.val;
  },
  Shared sharedVal;
)


public class SampleHold extends Moduck{
  maker(SampleHold, dur holdTime){
    SampleHold ret;
    Shared shared;
    OUT(P_Trigger);
    IN(TrigHandler, (shared));
    IN(SetHandler, (shared));
    ret.addVal("holdTime", Util.toSamples(holdTime));
    ret.addVal("forever", false);
    return ret;
  }

  fun static SampleHold make(){
    make(0::ms) @=> SampleHold ret;
    samp =>  now;
    ret.setVal("forever", true);
    return ret;
  }
}
