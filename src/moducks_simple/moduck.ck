

public class Moduck extends ModuckBase {
  EventHandler handlers[0];
  string handlerKeys[0];

  fun void addIn(string tag, EventHandler h){
    handlerKeys << tag;
    this @=> h.parent;
    /* h.init(); */
    h @=> handlers[tag];
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

  fun int doHandle(string msg, int v){
    handlers[msg] @=> EventHandler handler;
    if(handler == null){
      <<<"Invalid event: "+msg>>>;
      return false;
    }else{
      handler.handle(v);
      return true;
    }
  }


  fun int getVal(string key){
    return values[key].i;
  }


  fun void setVal(string key, int v){
    IntRef.make(v) @=> values[key];
  }


  fun void setValRef(string key, IntRef v){
    v @=> values[key];
  }
}




