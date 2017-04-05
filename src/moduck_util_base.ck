
include(pulses.m4)
include(funcs.m4)

public class MBUtil{
  fun static ModuckP update(ModuckP m, string dstTag, ModuckP processor){
    return update(m, recv(dstTag), dstTag, processor);
  }


  fun static ModuckP update(ModuckP m, string srcTag, string dstTag, ModuckP processor){
    // TODO: Default value always 0 here..
    ModuckP.make(Value.make(0)) @=> ModuckP val;
    m => val.fromTo(srcTag, "value").c;

    return Repeater.make()
      => val.c
      => processor.c
      => m.to(dstTag).c
    ;
  }



  fun static ModuckP onlyHigh(){
    return ModuckP.make(Processor.make(NotEq.make(null), false));
  }

  fun static ModuckP onlyLow(){
    return ModuckP.make(Processor.make(Eq.make(null), false))
           => ModuckP.make(Inverter.make(0)).c;
  }
}
