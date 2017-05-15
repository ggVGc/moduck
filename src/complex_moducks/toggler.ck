include(song_macros.m4)
include(moduck_macros.m4)
include(funcs.m4)

public class Toggler{
  maker(Moduck, int initiallyOn){
    def(in, mk(Repeater, [P_Trigger, P_Toggle]));
    def(out, mk(Repeater));
    def(inSwitcher, mk(GateSwitch, false));

    in => inSwitcher.from(P_Toggle).c;

    inSwitcher
      => MBUtil.onlyHigh().from("0").c
      => mk(TrigValue, 0).c
      => out.c;

    inSwitcher
      => MBUtil.onlyHigh().from("1").c
      => mk(TrigValue, 0).c
      => mk(Inverter, 0).c
      => out.c;

    out => inSwitcher.to(P_Gate).c;

    if(initiallyOn){
      samp =>  now;
      in.doHandle(P_Toggle, IntRef.make(0));
    }

    return Wrapper.make(in, out);
  }

  fun static Moduck make(){
    return make(true);
  }

}
