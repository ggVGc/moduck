



public class ModuckBase{
  VEvent _outs[0];
  string _outKeys[0];


  fun void send(string tag, IntRef v){
    _outs[tag] @=> VEvent ev;
    if(ev == null){
      <<<"Invalid event send: "+tag>>>;
    }else{
      v @=> ev.val;
      ev.broadcast();
    }
  }


  fun void waitSend(dur delay, string tag, IntRef v){
    delay => now;
    send(tag, v);
  }

  fun void sendPulse(string tag, int v){
    send(tag, IntRef.make(v));
    spork ~ waitSend(samp, tag, null);
  }


  fun int getVal(string key){
    <<<"ModuckBase.getVal - Error: This should never trigger">>>;
    Machine.crash();
  }

  
  fun ModuckBase setVal(string key, IntRef v){
    <<<"ModuckBase.setVal - Error: This should never trigger">>>;
    Machine.crash();
  }

  fun ModuckBase setVal(string key, int v){
    return setVal(key, IntRef.make(v));
  }


  fun void onValueChange(string key, int oldVal, int newVal){ }

}




