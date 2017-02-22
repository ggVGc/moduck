include(macros.m4)


genHandler(RunHandler, "run",
  Shred @ looper;

  fun void loop(){
    while(true){
      parent.getVal("delta")::samp => now;
      parent.send(P_Clock, 0);
    }
  }
  HANDLE{
    if(looper != null){
      looper.exit();
      null @=> looper;
    }
    if(v){
      spork ~ loop() @=> looper;
    }
  },
)


genHandler(BpmHandler, "bpm",
  HANDLE{
    parent.setVal("delta", Util.toSamples(Util.bpmToDur(v)));
  },
)



public class ClockGen extends Moduck{
  fun static ClockGen make(float bpm){
    return make(Util.bpmToDur(bpm));
  }
  
  fun static ClockGen make(dur d){
    ClockGen ret;
    OUT(P_Clock);
    IN(RunHandler, ());
    IN(BpmHandler, ());
    ret.addVal("delta", Util.toSamples(d));
    return ret;
  }
}
