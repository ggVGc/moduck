public class Printer extends Moduck{
  "Printer" => string msg;

  fun void print(int v){
    <<< msg + "> " + v>>>;
  }

  fun int handle(string msg, int v){
    print(v);
    return true;
  }

  fun static Printer make(string msg){
    Printer ret;
    msg => ret.msg;
    return ret;
  }
}

