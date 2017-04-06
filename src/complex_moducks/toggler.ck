include(macros.m4)
include(song_macros.m4)
include(funcs.m4)

public class Toggler{
  maker(Moduck, int initiallyOn){
    def(in, mk(Repeater, [P_Trigger, P_Toggle]));
    def(toggleIn, in => mk(Repeater).from(P_Toggle).c);
    def(inSwitcher, mk(Switcher, false));

    def(on, mk(TrigValue, 0));
    def(off, mk(TrigValue, 0) => mk(Inverter, 0).c);

    def(out, mk(Repeater));

    toggleIn => inSwitcher.c;
    inSwitcher => MBUtil.onlyHigh().from("0").c => on.c;
    inSwitcher => MBUtil.onlyHigh().from("1").c => off.c;

    def(activeRep, mk(Repeater));
    on => activeRep.c;
    off => activeRep.c;

    activeRep => inSwitcher.to(P_Gate).c;
    activeRep => out.c;

    if(initiallyOn){
      samp =>  now;
      in.doHandle(P_Toggle, IntRef.make(0));
    }

    out => mk(Printer, "Togg Active").c;

    return Wrapper.make(in, out);
  }

  fun static Moduck make(){
    return make(true);
  }

}
