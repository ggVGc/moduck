
include(macros.m4)

genHandler(TrigHandler, Pulse.Trigger(),
  HANDLE{
    parent.send(Pulse.Trigger(), v);
  }
  ;
)


public class Repeater extends Moduck{
  fun static Repeater make(){
    Repeater ret;
    OUT(Pulse.Trigger());
    IN(TrigHandler, ());
    return ret;
  }
}
