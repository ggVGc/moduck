
class Run extends EventHandler{
  dur delta;
  Shred @ looper;

  fun void loop(){
    while(true){
      delta => now;
      parent.send(Pulse.Clock(), 0);
    }
  }

  fun void handle(int v){
    if(looper != null){
      looper.exit();
      null @=> looper;
    }
    if(v){
      spork ~ loop() @=> looper;
    }
  }

  fun static Run make(dur delta){
    Run ret;
    delta => ret.delta;
    return ret;
  }
}


public class ClockGen extends Moduck{
  event(Pulse.Clock());

  fun static ClockGen make(dur delta){
    ClockGen ret;
    ret.handler("run", Run.make(delta));
    return ret;
  }
}
