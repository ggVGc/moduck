public class Offset extends Handler{
  fun int handle(string tag, int v){
    v + values["offset"].i => int x;
    x => out.val;
    tag => out.tag;
    out.broadcast();
    return true;
  }

  fun static Offset make(int off){
    Offset ret;
    Util.setVal(ret, "offset", off);
    return ret;
  }
}

