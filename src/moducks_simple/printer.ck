
include(macros.m4)



genHandler(PrintHandler, "print",
  fun void handle(int v){
    <<<msg + ">" + ":" + v >>>;
  },
  string msg;
)



public class Printer extends Moduck{
  fun static Printer make(string msg){
    Printer ret;
    IN(PrintHandler, (msg));
    return ret;
  }
}

