
include(song_macros.m4)
include(moduck_macros.m4)


genHandler(SetHandler, P_Set, 
    HANDLE{
      true => shouldTrigger.i;
      val.setFromRef(v);
    },
    MayInt val;
    IntRef shouldTrigger;
)

genHandler(TrigHandler, P_Trigger, 
    IntRef tmpRef;
    HANDLE{
      if(v != null){
        if(shouldTrigger.i){
          if(val.valid){
            v.i => tmpRef.i;
            parent.send(P_Trigger, tmpRef);
          }else{
            parent.send(P_Trigger, null);
          }
        }
        false => shouldTrigger.i;
      }
    },
    MayInt val;
    IntRef shouldTrigger;
)


genHandler(ClearHandler, P_Clear, 
    HANDLE{
      if(v != null){
        false => shouldTrigger.i;
      }
    },
    IntRef shouldTrigger;
)

public class OnceTrigger extends Moduck{
  maker0(Moduck){
    OnceTrigger ret;
    OUT(P_Trigger);
    MayInt val;
    IntRef.make(false) @=> IntRef shouldTrigger;
    IN(TrigHandler, (val, shouldTrigger));
    IN(SetHandler, (val, shouldTrigger));
    IN(ClearHandler, (shouldTrigger));
    return ret;
  }
}


/* 
 public class OnceTrigger{
   maker0(Moduck){
     def(in, mk(Repeater, [P_Trigger, P_Set, P_Clear]));
     def(out, mk(Repeater));
 
     def(blk, mk(Blocker));
     def(blkControl, mk(SampleHold) => blk.to(P_Gate).c);
     blkControl.set("triggerOnSet", true);
 
     in
       => frm(P_Set).c
       => MBUtil.onlyHigh().c
       => blkControl.to(P_Set).c;
 
     in
       => frm(P_Set).c
       => MBUtil.onlyLow().c
       => mk(Inverter, 0).c
       => in.to(P_Clear).c;
 
     in
       => frm(P_Clear).c
       => MBUtil.onlyHigh().c
       => mk(Inverter).c
       => blkControl.to(P_Set).c;
 
     in
       => frm(P_Trigger).c
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
 */
