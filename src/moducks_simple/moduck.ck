

public class Moduck extends ModuckBase {
  EventHandler handlers[0];
  string handlerKeys[0];

  fun void addIn(string tag, EventHandler h){
    handlerKeys << tag;
    this @=> h.parent;
    h @=> handlers[tag];
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

}




