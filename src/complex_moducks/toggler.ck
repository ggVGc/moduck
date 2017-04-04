include(macros.m4)
include(song_macros.m4)
include(funcs.m4)

public class Toggler{

  fun static Moduck make(){
    return make(true);
  }

  maker(Moduck, int initiallyOn){
    def(in, mk(Repeater, [P_Trigger, P_Toggle]));
    def(switcher, mk(Switcher));
    def(hold, mk(SampleHold));
    def(blockerA, mk(Blocker));
    def(blockerB, mk(Blocker));
    def(inverter, mk(Inverter, 0));
    def(inToggle, mk(Processor, Not.make(Eq.make(null))));

    def(on, mk(Value, 0));
    def(off, mk(Value, 0) => mk(Inverter, 0).c);

    def(out, mk(Repeater, [P_Trigger, P_Active]));

    in
      .b(inToggle)
      .b(switcher => out.c)
    ;

    inToggle
      .b(blockerA => out.fromTo(recv(P_Gate), P_Active).c)
      .b(blockerB)
    ;

    blockerA => off.c => hold.to(P_Set).c;
    blockerB => on.c => hold.to(P_Set).c;

    hold
      .b(inverter => blockerB.to(P_Gate).c)
      .b(blockerA.to(P_Gate))
      .b(switcher.to(P_Gate))
      .b(hold.fromTo(recv(P_Set), P_Trigger))
    ;

    hold.setVal("triggerOnSet", true);
    samp =>  now;
    if(initiallyOn){
      hold.doHandle(P_Set, null);
    }else{
      hold.doHandle(P_Set, IntRef.make(0));
    }

    return Wrapper.make(in, out);
  }
}
