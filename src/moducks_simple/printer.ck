
include(macros.m4)



genHandler(PrintHandler, "print",
  fun void handle(int v){
    <<<msg + ">" + ":" + v >>>;
    parent.send(Pulse.Trigger(), v);
  },
  string msg;
)



public class Printer extends Moduck{
  fun static Printer make(string msg){
    Printer ret;
    OUT(Pulse.Trigger());
    IN(PrintHandler, (msg));
    return ret;
  }
}

