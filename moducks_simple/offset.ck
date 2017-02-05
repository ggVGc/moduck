public class Offset extends Moduck{
  fun int handle(string tag, int v){
    send(tag, v + values["offset"].i);
    return true;
  }

  fun static Offset make(int off){
    Offset ret;
    ret.setVal("offset", off);
    return ret;
  }
}

