
public class Repeater extends Moduck{
  string relabel;
  fun int handle(string tag, int v){
    if(relabel != null){
      relabel => out.tag;
    }else{
      tag => out.tag;
    }

    v => out.val;
    out.broadcast();
    return true;
  }

  fun static Repeater make(){
    Repeater ret;
    return ret;
  }
}
