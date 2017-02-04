

public class Trigger extends Handler{
  fun void trigger(string tag, int v){
    tag => out.tag;
    v => out.val;
    out.broadcast();
  }
}

