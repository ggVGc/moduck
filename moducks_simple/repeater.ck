
public class Repeater extends Moduck{
  string relabel;
  now => time lastTime;
  fun int handle(string tag, int v){
    if(relabel != null){
      relabel => out.tag;
    }else{
      tag => out.tag;
    }

    // Delay event if multiple are received in the same frame
    // Otherwise receivers miss all events except the first
    if(now == lastTime){
      samp => now;
    }

    now => lastTime;

    v => out.val;
    out.broadcast();
    return true;
  }

  fun static Repeater make(){
    Repeater ret;
    return ret;
  }
}
