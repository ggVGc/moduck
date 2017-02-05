
public class Mapper extends Moduck{

  int entries[];

  fun int handle(string tag, int v){
    entries[v] => out.val;
    out.broadcast();
    return true;
  }

  fun static Mapper make(int entries[]){
    Mapper ret;
    entries @=> ret.entries;
    return ret;
  }
}
