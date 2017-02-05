
// This entire thing is a huge hack to make sure no events fire at the same time
// which causes various issues
// It's probably completely broken in some other way
class Dispatcher{
  now => time lastSendTime;
  now => time lastDelayedSend;
  0 => int offset;


  fun void delaySend(SrcEvent out, string tag, int val){
    if(now - lastDelayedSend > 200::samp){
      /* <<<"Resetting delayed send">>>; */
      1 => offset;
    }else{
      1+offset => offset;
    }

    offset::samp => now;
    /* <<<"DelayedOut: "+ Util.strOrNull(tag) +":"+val>>>; */
    val => out.val;
    tag => out.tag;
    out.broadcast();
    now => lastDelayedSend;
  }

  fun void send(SrcEvent out, string tag, int val){
    if(now - lastSendTime < 10::samp){
      spork ~ delaySend(out, tag, val);
      /* <<<"Delayed:"+Util.strOrNull(tag)+":"+val>>>; */
    }else{
    /* <<<"Out: "+ tag+":"+val>>>; */
      val => out.val;
      tag => out.tag;
      out.broadcast();
      /* <<<"Normal:"+Util.strOrNull(tag)+":"+val>>>; */
    }
    now => lastSendTime;
  }

  fun static Dispatcher make(){
    Dispatcher ret;
    return ret;
  }
}

public class Moduck{
  IntRef values[10]; // Completely arbitrary
  SrcEvent out;

  now => time lastSend;

  static Dispatcher @ dispatcher;


  fun void send(string tag, int v){
    /* if(tag == null){ */
    /*   srcMsg => tag; */
    /* } */
    if(now - lastSend < 10::samp){
      10::samp => now;
    }
    now => lastSend;
    dispatcher.send(out, tag, v);
  }

  fun int handle(string msg, int v){};

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

Dispatcher.make() @=> Moduck.dispatcher;




