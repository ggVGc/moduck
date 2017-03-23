



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


  fun int getVal(string key){
    <<<"ModuckBase.getVal - Error: This should never trigger">>>;
    Machine.crash();
  }


  fun ModuckBase setVal(string key, int v){
    <<<"ModuckBase.setVal - Error: This should never trigger">>>;
    Machine.crash();
  }
}




