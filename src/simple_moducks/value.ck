
include(macros.m4)

public class Value extends Moduck{
  fun static SampleHold make(int v){
    return make(IntRef.make(v));
  }
  fun static SampleHold make(IntRef v){
    SampleHold.make(0::ms) @=> SampleHold ret;
    ret.setVal("forever", true);
    samp => now;
    if(v != null){
      ret.doHandle(P_Set, v);
    }
    return ret;
  }

  fun static SampleHold False(){
    return Value.make(false);
  }
  fun static SampleHold True(){
    return Value.make(true);
  }
}
