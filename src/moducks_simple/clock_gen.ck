include(macros.m4)

genHandler(RunHandler, "run",
  Shred @ looper;

  fun void loop(){
    while(true){
      delta => now;
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
  dur delta;
)


public class ClockGen extends Moduck{
  fun static ClockGen make(dur delta){
    ClockGen ret;
    OUT(P_Clock);
    IN(RunHandler, (delta));
    return ret;
  }
}
