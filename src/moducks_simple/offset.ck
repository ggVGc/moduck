
include(macros.m4)

genHandler( TrigHandler, Pulse.Trigger(), HANDLE{
    parent.send(Pulse.Trigger(), v + parent.getVal("offset"));
  },
;)



public class Offset extends Moduck{

  fun static Offset make(int off){
    Offset ret;
    ret.setVal("offset", off);
    OUT(Pulse.Trigger());
    IN(TrigHandler, ());
    return ret;
  }
}

