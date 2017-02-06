
include(macros.m4)



genHandler( Print,{
  <<<msg + ">" + ":" + v >>>;
},
string msg;)



public class Printer extends Moduck{
  "Printer" => string msg;

  fun static Printer make(string msg){
    Printer ret;
    ret.IN(Pulse.Trigger(), Print.make(msg));
    return ret;
  }
}

