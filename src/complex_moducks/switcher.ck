
include(macros.m4)
include(song_macros.m4)

public class Switcher{
  maker0(Moduck){
    Repeater.make([P_Trigger, P_Gate]) @=> Repeater in;
    Inverter.make(0) @=> Inverter inverter;
    Router.make(0) @=> Router router;
    Patch.connect(in, P_Trigger, router, P_Trigger);

    Value.make(0) @=>  Moduck v0;
    Value.make(1) @=>  Moduck v1;

    Patch.connect(in, P_Gate, v1, P_Trigger);

    Patch.connect(in, P_Gate, inverter, P_Trigger);
    Patch.connect(inverter, P_Trigger, v0, P_Trigger);
    Patch.connect(v0, P_Trigger, router, "index");
    Patch.connect(v1, P_Trigger, router, "index");

    return Wrapper.make(in, router);
  }
}
