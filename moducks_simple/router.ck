
public class Router extends Moduck{
  fun int handle(string tag, int v){
    "" + getVal("index") => out.tag;
    v => out.val;
    out.broadcast();
    return true;
  }
  

  fun static Router make(int startIndex){
    Router ret;
    ret.setVal("index", startIndex);
    return ret;
  }
}
