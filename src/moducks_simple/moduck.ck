
include(pulses.m4)



public class Moduck extends ModuckBase {
  EventHandler _handlers[0];
  string handlerKeys[0];
  ValueSetHandler _valHandlers[0];
  string _valHandlerKeys[0];


  fun void addIn(string tag, EventHandler h){
    addOut(recv(tag));
    handlerKeys << tag;
    this @=> h.parent;
    h @=> _handlers[tag];
  }


  fun void addOut(string tag){
    _outKeys << tag;
    VEvent ev;
    ev @=> _outs[tag];
  }


  /*
    fun void addDefaultIn(string tag, EventHandler h){
      addIn(tag, h);
      tag => _defaultHandlerTag;
    }
   */


  /*
    fun void addDefaultOut(string tag){
      addOut(tag);
      tag => _defaultOutputTag;
    }
   */



  fun void addVal(string tag, int initialValue){
    ValueSetHandler.make(this, tag, initialValue) @=> ValueSetHandler h;
    addIn(tag, h.getEvHandler());
    h @=> _valHandlers[tag];
    _valHandlerKeys << tag;
  }

  fun ModuckBase setVal(string tag, int v){
    doHandle(tag, v);
    samp => now;
    return this;
  }

  fun string findDefaultInputTag(){
    for(0=>int i;i<handlerKeys.size();++i){
      handlerKeys[i] @=> string k;
      if(!Util.contains(k, _valHandlerKeys)){
        return k;
      }
    }

    <<< "Error: No inputs present", this >>>;

    return null;
  }


  fun string findDefaultOutputTag(){
    filterNonRecvPulses(_outKeys) @=> string nonRecvs[];
    if(nonRecvs.size() == 0){
      <<< "Error: No inputs present", this >>>;
      return null;
    }

    return nonRecvs[0];
  }

  fun int doHandle(string tag, int v){
    if(tag == P_Default){
      findDefaultInputTag() @=> tag;
    }


    _handlers[tag] @=> EventHandler handler;
    if(handler == null){
      <<<"Invalid event: "+tag>>>;
      return false;
    }else{
      handler.handle(v);
      handler.parent.send(recv(tag), v);
      return true;
    }
  }

  fun int getVal(string tag){
    return _valHandlers[tag].curVal;
  }


  fun VEvent getOut(string tag){
    if(tag == P_Default){
      findDefaultOutputTag() @=> tag;
    }
    return _outs[tag];
  }

}





class ValueSetHandler extends EventHandler{
  string tag;
  int curVal;
  fun void handle(int val){
    val @=> curVal;
    samp => now;
  }

  fun static ValueSetHandler make(Moduck owner, string tag, int initialVal){
    ValueSetHandler ret;
    owner @=> ret.parent;
    tag @=> ret.tag;
    initialVal @=> ret.curVal;
    return ret;
  }

  fun EventHandler getEvHandler(){
    return this;
  }
}

