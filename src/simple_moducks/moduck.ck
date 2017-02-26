
include(pulses.m4)



public class Moduck extends ModuckBase {
  EventHandler _handlers[0];
  string handlerKeys[0];
  ValueSetHandler _valHandlers[0];
  string _valHandlerKeys[0];
  false => int persisting;

  // int outCache[0];

  "-" @=> string name;



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


  fun void _writePersistVal(string persistPath, string tag, int val){
    FileIO fout;
    fout.open(persistPath+"_"+tag, FileIO.WRITE );

    // test
    if(!fout.good()){
      <<<"can't open file for writing...: "+persistPath+"_"+tag>>>;
    }else{
      fout <= val;
      fout.close();
    }
  }

  fun void _outCacheSetter(string persistFileName, string tag){
    while(true){
      _outs[tag] @=> VEvent ev;
      ev => now;
      _writePersistVal(persistFileName, tag, ev.val);
    }
  }


  fun void addVal(string tag, int initialValue){
    ValueSetHandler.make(this, tag, initialValue) @=> ValueSetHandler h;
    addIn(tag, h.getEvHandler());
    h @=> _valHandlers[tag];
    _valHandlerKeys << tag;
    addOut(tag);
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

  fun void _onRunnerStart(string persistFileName){
    RunnerBase._startBang => now;
    for(0=>int i;i<_outKeys.size();++i){
      _outKeys[i] @=> string k;
      FileIO fio;
      fio.open( persistFileName+"_"+k, FileIO.READ );
      if(fio.good()){
        int val;
        fio => val;
        fio.close();
        this.send(k, val);
      }
    }
  }

  fun void doPersist(string fileName){
    true => persisting;
    for(0=>int i;i<_outKeys.size();++i){
      spork ~ _outCacheSetter(fileName, _outKeys[i]);
    }
    spork ~ _onRunnerStart(fileName);
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
      <<<name+": Invalid event: "+tag>>>;
      return false;
    }else{
      /*
        if(persistVals != null){
          null @=> persistVals;
          persistVals[tag] @=> IntRef val;
          if(val != null){
            val.i => v;
            <<< "restired val", tag, v>>>;
          }
        }
       */

      handler.handle(v);
      handler.parent.send(recv(tag), v);
      return true;
    }
  }

  fun int hasHandler(string tag){
    return _handlers[tag] != null;
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
  // null @=> string persistPath;

  fun void handle(int val){
    val @=> curVal;
    // if(persistPath != null){
    //   _writePersistVal();
    // }
    parent.send(tag, curVal);
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

