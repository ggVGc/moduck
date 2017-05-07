include(macros.m4)


// TODO: This should use a gate signal instead
genHandler(RunHandler, "run",
  Shred @ looper;

  fun void loop(){
    while(true){
      /* parent.getVal("delta")::samp => now; */
      minute / bpm.i => now;
      parent.sendPulse(P_Clock, 0);
    }
  }

  fun void stop(){
    if(looper != null){
      looper.exit();
      null @=> looper;
    }
  }

  HANDLE{
    stop();
    if(null != v && v.i){
      spork ~ loop() @=> looper;
    }
  },
  IntRef bpm;
)


/* 
 genHandler(BpmHandler, "bpm",
   HANDLE{
     if(null != v){
       parent.setVal("delta", Util.toSamples(Util.bpmToDur(v.i)));
     }
   },
 )
 */

public class ClockGen extends Moduck{
  RunHandler @ runHandler;
  IntRef bpm;

  fun void stop(){
    runHandler.stop();
  }


  /* 
   fun static ClockGen make(int bpm){
     return make(Util.bpmToDur(bpm));
   }
   */

  
  fun static ClockGen make(int bpm){
    ClockGen ret;
    bpm => ret.bpm.i;
    OUT(P_Clock);
    IN(RunHandler, (ret.bpm)) @=> ret.runHandler;
    /* IN(BpmHandler, ()); */
    /* Util.toSamples(d) => int xxx; */
    /* ret.addVal("delta", xxx); */
    /* <<<xxx>>>; */
    return ret;
  }
}
