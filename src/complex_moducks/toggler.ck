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

    def(outBlocker, mk(Blocker));
    def(out, mk(Repeater, [P_Trigger, P_Active]));

    toggleIn => inSwitcher.c;
    inSwitcher => MBUtil.onlyHigh().from("0").c => on.c;
    inSwitcher => MBUtil.onlyHigh().from("1").c => off.c;

    def(activeRep, mk(Repeater));
    on => activeRep.c;
    off => activeRep.c;

    activeRep => inSwitcher.to(P_Gate).c;
    activeRep => outBlocker.to(P_Gate).c;

    in => outBlocker.c => out.c;
    outBlocker => out.fromTo(recv(P_Gate), P_Active).c;
    return Wrapper.make(in, out);
  }

  fun static Moduck make(){
    return make(true);
  }

}
