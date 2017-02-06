
public class Router extends Moduck{
  fun int handle(string tag, int v){
    send("" + getVal("index"), v);
    return true;
  }
  

  fun static Router make(int startIndex){
    Router ret;
    ret.setVal("index", startIndex);
    return ret;
  }
}
