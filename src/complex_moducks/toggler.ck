include(macros.m4)
include(song_macros.m4)

public class Toggler{
  maker0(Moduck){
    Repeater.make([P_Trigger, P_Toggle]) @=> Repeater in;
    Switcher.make() @=> Moduck switcher;
    SampleHold.make() @=> SampleHold hold;
    Blocker.make() @=> Moduck blockerA;
    Blocker.make() @=> Moduck blockerB;
    Inverter.make(0) @=>  Moduck inverter;

    Value.make(0) @=> Moduck on;
    Patch.connect(Value.make(0), Inverter.make(0)) @=> Moduck off;

    Patch.connect(in, P_Toggle, blockerA, P_Trigger);
    Patch.connect(in, P_Toggle, blockerB, P_Trigger);

    Patch.connect(blockerA, off);
    Patch.connect(blockerB, on);

    Patch.connect(on, P_Trigger, hold, P_Set);
    Patch.connect(off, P_Trigger, hold, P_Set);

    Patch.connect(hold, recv(P_Set), hold, P_Trigger);

    Patch.connect(hold, P_Trigger, inverter, P_Trigger);
    Patch.connect(inverter, P_Trigger, blockerB, P_Gate);
    Patch.connect(hold, P_Trigger, blockerA, P_Gate);

    Patch.connect(hold, P_Trigger, switcher, P_Gate);
    Patch.connect(in, P_Trigger, switcher, P_Trigger);

    hold.setVal("triggerOnSet", true);
    samp =>  now;
    hold.doHandle(P_Set, null);


    return Wrapper.make(in, switcher);
  }
}
