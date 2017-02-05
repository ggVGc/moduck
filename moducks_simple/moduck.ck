
public class Moduck{
  IntRef values[10]; // Completely arbitrary
  SrcEvent out;

  now => time lastSendTime;

  fun int handle(string msg, int v){};

  fun void delaySend(string tag, int val){
    samp => now;
    /* <<<"DelayedOut: "+ Util.strOrNull(tag) +":"+val>>>; */
    tag => out.tag;
    val => out.val;
    out.broadcast();
  }

  fun void send(string tag, int val){
    // Delay event if multiple are received in the same frame
    // Otherwise receivers miss all events except the first
    if(tag == null){
      out.tag => tag;
    }
    if(now == lastSendTime){
      spork ~ delaySend(tag, val);
    }else{
      val => out.val;
      tag => out.tag;
    /* <<<"Out: "+ tag+":"+val>>>; */
      out.broadcast();
    }
    now => lastSendTime;
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
