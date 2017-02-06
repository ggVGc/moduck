
include(macros.m4)

genHandler( Trig, {
  parent.send(Pulse.Trigger(), v + parent.getVal("offset"));
},
;)



public class Offset extends Moduck{
  OUT(Pulse.Trigger());
  IN(Pulse.Trigger(), Trig.make(off));

  fun static Offset make(int off){
    Offset ret;
    ret.setVal("offset", off);
    return ret;
  }
}

