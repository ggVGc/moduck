
include(macros.m4)
include(song_macros.m4)


genHandler(TrigHandler, P_Trigger, 
  Shred @ shred;


  fun void doWait(){
    parent.getVal("holdTime")::samp => now;
    parent.send(P_Trigger, null);
  }


  HANDLE{
    if(null != v){
      if(null != shred){
        shred.exit();
        null @=> shred;
      }
      parent.send(P_Trigger, v);
      spork ~ doWait() @=> shred;
    }
  },
  ;
)


public class SampleHold extends Moduck{
  maker(SampleHold, dur holdTime){
    SampleHold ret;

    OUT(P_Trigger);
    IN(TrigHandler, ());

    ret.addVal("holdTime", Util.toSamples(holdTime));
      
    return ret;
  }
}
