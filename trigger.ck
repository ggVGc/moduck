

public class Trigger extends Moduck{
  fun void trigger(string tag, int v){
    tag => out.tag;
    v => out.val;
    out.broadcast();
  }
}

