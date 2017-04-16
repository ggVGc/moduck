include(macros.m4)
include(song_macros.m4)

public class TrigValue extends Moduck{
  fun static Moduck make(IntRef v){
    def(val, mk(Value, v));
    def(in, mk(Repeater, [P_Trigger, P_Set]));
    def(out, mk(Repeater));

    val => out.c;

    in => val.listen([P_Trigger, P_Set]).c;
    in => MBUtil.onlyLow().c => out.c;
    samp =>  now;
    out => mk(Printer, "diddles").c;
    return Wrapper.make(in, out);
  }

  fun static Moduck make(int v){
    return make(IntRef.make(v));
  }

  fun static Moduck False(){
    return make(false);
  }
  fun static Moduck True(){
    return make(true);
  }
}
