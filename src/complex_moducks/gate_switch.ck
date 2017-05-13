
include(song_macros.m4)

public class GateSwitch{

  fun static Moduck make(){
    return make(true);
  }

  maker(Moduck, int outOnChange){
    def(in, mk(Repeater, [P_Trigger, P_Gate, "outOnChange"]));

    Inverter.make(0) @=> Inverter inverter;
    def(router, mk(Router, 0, outOnChange));
    in => router.listen("outOnChange").c;
    /* router.doHandle(P_Trigger, IntRef.make(0)); */
    Patch.connect(in, P_Trigger, router, P_Trigger);

    TrigValue.make(0) @=>  Moduck v0;
    TrigValue.make(1) @=>  Moduck v1;

    Patch.connect(in, P_Gate, v1, P_Trigger);

    Patch.connect(in, P_Gate, inverter, P_Trigger);
    Patch.connect(inverter, P_Trigger, v0, P_Trigger);
    Patch.connect(v0, P_Trigger, router, "index");
    Patch.connect(v1, P_Trigger, router, "index");

    return Wrapper.make(in, router);
  }
}
