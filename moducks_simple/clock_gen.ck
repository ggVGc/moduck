
public class ClockGen extends Moduck{

  dur delta;
  Shred @ looper;

  fun void loop(){
    while(true){
      delta => now;
      out.broadcast();
    }
  }

  fun int handle(string msg, int v){
    if(msg == "run"){
      if(looper != null){
        looper.exit();
        null @=> looper;
      }
      if(v){
        spork ~ loop() @=> looper;
      }
      return true;
    }
  }

  fun static ClockGen make(int bpm){
    ClockGen ret;
    Util.bpmToDur(bpm) => ret.delta;
    return ret;
  }
}
