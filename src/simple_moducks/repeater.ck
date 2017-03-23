
include(macros.m4)
include(pulses.m4)

class RepeatHandler extends EventHandler{
  string pulseTag;


  fun void handle(IntRef v){
    parent.send(pulseTag, v);
  }


  fun static RepeatHandler make(string tag){
    RepeatHandler ret;
    tag => ret.pulseTag;
    return ret;
  }


  fun void add(Moduck parent){
    parent.addIn(pulseTag, this);
  }
}


public class Repeater extends Moduck{

  fun static Repeater make(string tags[]){
    Repeater ret;
    for(0=>int i;i<tags.size();++i){
      OUT(tags[i]);
      IN(RepeatHandler, (tags[i]));
    }
    return ret;
  }


  fun static Repeater make(string tag){
    return make([tag]);
  }


  fun static Repeater make(){
    return make(P_Trigger);
  }

  /*
    fun static Repeater make(Moduck m){
      filterNonRecvPulses(m.handlerKeys) @=> string keys[];
      make(keys) @=> Repeater ret;
      for(0=>int i;i<keys.size();++i){
        Patch.
        m => ret.fromTo(recv(k), k).c;
      }
      return ret;
    }
   */
}
