
include(pulses.m4)
include(moduck_macros.m4)


public class Moduck extends ModuckBase {
  EventHandler _handlers[0];
  string handlerKeys[0];
  ValueSetHandler _valHandlers[0];
  string _valHandlerKeys[0];
  false => int persisting;

  IntRef outCache[0];
  string persistFileName;

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

  fun void _writePersistVal(string persistPath, string tag, int val){
    FileIO fout;
    fout.open(persistPath+"_"+tag, FileIO.WRITE );

    if(!fout.good()){
      <<<"can't open file for writing...: "+persistPath+"_"+tag>>>;
    }else{
      fout <= val;
      fout.close();
    }
  }

  // TODO: Persistance related
  /* 
   fun void _outCacheWriter(string persistFileName, string tag){
     while(true){
       _outs[tag] @=> VEvent ev;
       ev => now;
       IntRef.make(ev.val) @=> outCache[tag];
       if(persisting){
         _writePersistVal(persistFileName, tag, ev.val);
       }
     }
   }
   */

  fun void addVal(string tag, int initialValue){
    ValueSetHandler.make(this, tag, initialValue) @=> ValueSetHandler h;
    addIn(tag, h.asEventHandler());
    h @=> _valHandlers[tag];
    _valHandlerKeys << tag;
    addOut(tag);
  }


  fun ModuckBase setVal(string tag, IntRef v){
    doHandle(tag, v);
    samp => now;
    return this;
  }


  fun int hasValue(string tag){
    return Util.contains(tag, _valHandlerKeys);
  }

  fun string findDefaultInputTag(){
    for(0=>int i;i<handlerKeys.size();++i){
      handlerKeys[i] @=> string k;
      if(!hasValue(k)){
        return k;
      }
    }

    <<< "Error: No inputs present", this >>>;

    return null;
  }

  fun void _onRunnerStart(){
    RunnerBase._preStartBang => now;

    for(0=>int i;i<_outKeys.size();++i){
      _outKeys[i] @=> string k;

      // TODO: Persistance related
      /* 
       spork ~ _outCacheWriter(persistFileName, k);
       */

      // Persistance related
      /* 
       FileIO fio;
       fio.open( persistFileName+"_"+k, FileIO.READ );
       if(fio.good()){
         int val;
         fio => val;
         fio.close();
         if(isRecvPulse(k)){
           doHandle(unRecv(k), val);
         }else{
           send(k, val);
         }
       }
       */
    }
  }

  fun void doPersist(string fileName){
    true => persisting;
    fileName @=> persistFileName;
  }
  spork ~ _onRunnerStart();


  fun string findDefaultOutputTag(){
    filterNonRecvPulses(_outKeys) @=> string nonRecvs[];
    if(nonRecvs.size() == 0){
      <<< "Error: No inputs present", this >>>;
      return null;
    }

    return nonRecvs[0];
  }


  fun int doHandle(int v){
    return doHandle(P_Default, IntRef.make(v));
  }

  fun int doHandle(IntRef v){
    return doHandle(P_Default, v);
  }


  fun int doHandle(string tag, int v){
    return doHandle(tag, IntRef.make(v));
  }

  fun int doHandle(string tag, IntRef v){
    if(tag == P_Default){
      findDefaultInputTag() @=> tag;
    }

    _handlers[tag] @=> EventHandler handler;
    if(handler == null){
      <<<name+": Invalid event: "+tag>>>;
      return false;
    } else {
      // Persistance related
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

  fun string[] getSourceTags(){
    string ret[0];
    for(0 => int i; i<handlerKeys.size(); i++){
      handlerKeys[i] @=> string k;
        ret << k;
    }
    for(0 => int i; i<_valHandlerKeys.size(); i++){
      _valHandlerKeys[i] @=> string k;
      if(!isRecvPulse(k)){
        ret << k;
      }
    }
    return ret;
  }

  fun int hasHandler(string tag){
    return _handlers[tag] != null;
  }

  fun int getVal(string tag){
    if(!hasValue(tag)){
      WARNING("Getting invalid value: "+tag);
    }
    return _valHandlers[tag].curVal;
  }


  fun VEvent getOut(string tag){
    if(tag == P_Default){
      findDefaultOutputTag() @=> tag;
    }
    return _outs[tag];
  }

  fun void bang(){
    doHandle(P_Trigger, IntRef.make(0));
    samp =>  now;
    doHandle(P_Trigger, null);
  }

}


class ValueSetHandler extends EventHandler{
  string tag;
  int curVal;
  // null @=> string persistPath;


  fun void handle(IntRef val){
    if(null != val){
      parent.onValueChange(tag, curVal, val.i);
      val.i @=> curVal;
    }

    //TODO: Persistance related
    /* 
     if(persistPath != null){
       _writePersistVal();
     }
     */

    parent.send(tag, val);
    samp => now;
  }


  fun static ValueSetHandler make(ModuckBase owner, string tag, int initialVal){
    ValueSetHandler ret;
    owner @=> ret.parent;
    tag @=> ret.tag;
    initialVal @=> ret.curVal;
    return ret;
  }


  fun EventHandler asEventHandler(){
    return this;
  }
}

