public class Offset extends Moduck{
  fun int handle(string tag, int v){
    v + values["offset"].i => int x;
    x => out.val;
    tag => out.tag;
    out.broadcast();
    return true;
  }

  fun static Offset make(int off){
    Offset ret;
    ret.setVal("offset", off);
    return ret;
  }
}

