

public class ModuckBase{
  IntRef values[0]; // Completely arbitrary sizes
  VEvent outs[0];
  string outKeys[0];

  fun int hasValueKey(string key){
    return values[key] != null;
  }
  
  fun void addOut(string tag){
    outKeys << tag;
    VEvent ev;
    ev @=> outs[tag];
  }

  fun void send(string tag, int v){
    outs[tag] @=> VEvent ev;
    if(ev == null){
      <<<"Invalid event send: "+tag>>>;
    }else{
      v => ev.val;
      ev.broadcast();
    }
  }


  fun int getVal(string key){
    return values[key].i;
  }

  // fun void onValChange(string key, int v){}

  fun int getVal(string key){
    return values[key].i;
  }


  fun ModuckBase setVal(string key, int v){
    return setValRef(key, IntRef.make(v));
  }


  fun ModuckBase setValRef(string key, IntRef v){
    /*
      <<<now>>>;
      <<<"Setting val "+key+" = "+v+" ">>>;
     */
    v @=> values[key];
    outs[key] @=> VEvent @ ev;
    if(ev == null){
      VEvent newEv;
      newEv @=> ev;
      ev @=> outs[key];
      outKeys << key;
    }

    
    send(key, v.i);
    // onValChange(key, v.i);
    return this;
  }
}




