
public class Repeater extends Moduck{
  fun int handle(string tag, int v){
    tag => out.tag;
    v => out.val;
    out.broadcast();
    return true;
  }

  fun static Repeater make(){
    Repeater ret;
    return ret;
  }
}
