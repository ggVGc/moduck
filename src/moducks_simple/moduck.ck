
include(pulses.m4)

public class Moduck extends ModuckBase {
  EventHandler handlers[0];
  string handlerKeys[0];

  fun void addIn(string tag, EventHandler h){
    addOut(recv(tag));
    handlerKeys << tag;
    this @=> h.parent;
    h @=> handlers[tag];
  }


  fun int doHandle(string tag, int v){
    handlers[tag] @=> EventHandler handler;
    if(handler == null){
      <<<"Invalid event: "+tag>>>;
      return false;
    }else{
      handler.handle(v);
      handler.parent.send(recv(tag), v);
      return true;
    }
  }

}




