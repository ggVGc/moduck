
include(macros.m4)
include(song_macros.m4)


class Shared{
  IntRef val;
}

genHandler(TrigHandler, P_Trigger, 
  Shred @ shred;

  fun void doWait(){
    parent.getVal("holdTime")::samp => now;
    parent.send(P_Trigger, null);
  }


  HANDLE{
    if(null != v && null != sharedVal.val){
      if(null != shred){
        shred.exit();
        null @=> shred;
      }
      parent.send(P_Trigger, sharedVal.val);
      spork ~ doWait() @=> shred;
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
    return ret;
  }
}
