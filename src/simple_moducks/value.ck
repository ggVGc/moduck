include(macros.m4)

/* 
 genHandler(TrigHandler, P_Trigger,
   HANDLE{
     if(null != v){
       parent.send(P_Trigger, IntRef.make(parent.getVal("value")));
     }else{
       parent.send(P_Trigger, null);
     }
   },
   ;
 )
 
 
 public class Value extends Moduck{
   fun static Value make(int v){
     Value ret;
     OUT(P_Trigger);
     IN(TrigHandler, ());
 
     ret.addVal("value", v);
 
     return ret;
   }
 
   fun static Value False(){
     return Value.make(false);
   }
   fun static Value True(){
     return Value.make(true);
   }
 }
 */


include(macros.m4)

public class Value extends Moduck{
  fun static SampleHold make(int v){
    SampleHold.make(0::ms) @=> SampleHold ret;
    ret.setVal("forever", true);
    samp => now;
    ret.doHandle(P_Set, IntRef.make(v));
    return ret;
  }

  fun static SampleHold False(){
    return Value.make(false);
  }
  fun static SampleHold True(){
    return Value.make(true);
  }
}
