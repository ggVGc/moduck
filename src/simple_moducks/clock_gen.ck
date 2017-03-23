include(macros.m4)


// TODO: This should use a gate signal instead
genHandler(RunHandler, "run",
  Shred @ looper;

  fun void loop(){
    while(true){
      parent.getVal("delta")::samp => now;
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
)


genHandler(BpmHandler, "bpm",
  HANDLE{
    if(null != v){
      parent.setVal("delta", Util.toSamples(Util.bpmToDur(v.i)));
    }
  },
)


public class ClockGen extends Moduck{
  RunHandler @ runHandler;

  fun void stop(){
    runHandler.stop();
  }


  fun static ClockGen make(float bpm){
    return make(Util.bpmToDur(bpm));
  }

  
  fun static ClockGen make(dur d){
    ClockGen ret;
    OUT(P_Clock);
    IN(RunHandler, ()) @=> ret.runHandler;
    IN(BpmHandler, ());
    ret.addVal("delta", Util.toSamples(d));
    return ret;
  }
}
