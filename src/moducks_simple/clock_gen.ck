include(macros.m4)

genHandler(RunHandler, "run",
  Shred @ looper;

  fun void loop(){
    while(true){
      delta => now;
      parent.send(Pulse.Clock(), 0);
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
    OUT(Pulse.Clock());
    IN(RunHandler, (delta));
    return ret;
  }
}
