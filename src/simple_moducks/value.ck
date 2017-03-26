include(macros.m4)

public class Value extends Moduck{
  fun static SampleHold make(int v){
    SampleHold.make(0::ms) @=> SampleHold ret;
    ret.setVal("forever", true);
    return ret;
  }

  fun static SampleHold False(){
    return Value.make(false);
  }
  fun static SampleHold True(){
    return Value.make(true);
  }
}

