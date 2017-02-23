



public class ModuckBase{
  // IntRef _values[0];
  VEvent _outs[0];
  string _outKeys[0];

  /*
    fun int hasValueKey(string key){
      return _values[key] != null;
    }
   */
  

  fun void send(string tag, int v){
    _outs[tag] @=> VEvent ev;
    if(ev == null){
      <<<"Invalid event send: "+tag>>>;
    }else{
      v => ev.val;
      ev.broadcast();
    }
  }


  fun int getVal(string key){
    <<<"ModuckBase.getVal - Error: This should never trigger">>>;
  }


  fun ModuckBase setVal(string key, int v){
    <<<"ModuckBase.setVal - Error: This should never trigger">>>;
    return null;
  }


  fun ModuckBase setValRef(string key, IntRef v){
    <<<"ModuckBase.setValRef - Error: This should never trigger">>>;
    return null;
  }
}




