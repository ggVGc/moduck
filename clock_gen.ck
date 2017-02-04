
public class ClockGen extends Handler{
  /* VEvent out; */
  Util.bpmToDur(120) => dur delta;

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
}
