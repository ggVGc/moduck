include(macros.m4)
include(song_macros.m4)

public class OnceTrigger{
  maker0(Moduck){
    def(in, mk(Repeater, [P_Clock, P_Set]));
    def(out, mk(Repeater));
    def(blk, mk(Blocker));
    def(blkControl, mk(SampleHold) => blk.to(P_Gate).c);
    blkControl.set("triggerOnSet", true);

    in
      => frm(P_Set).c
      => MBUtil.onlyHigh().c
      => blkControl.to(P_Set).c
    ;

    in
      => blk.c
      => MBUtil.onlyHigh().c
      => mk(TrigValue, 0).c
      => out.c
      => ( MBUtil.onlyHigh() => mk(Delay, samp).c => mk(Inverter, 0).c => out.c).c
      => (Value.make(0) => mk(Inverter, 0).c => blkControl.to(P_Set).c).c;
    ;

    return mk(Wrapper, in, out);
  }
}

