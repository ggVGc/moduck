
include(moduck_macros.m4)

genHandler(TrigHandler, P_Trigger,
  HANDLE{
    if(null != v){
      parent.getVal("offsetPerPeriod") => int offs;
      int k;
      int rest;
      v.i => int val;
      if(val >= 0){
        val / entries.size() => rest;
        val % entries.size() => k;
      }else{
        val / entries.size() => rest;
        val % entries.size() => k;
        if(k < 0 ){
          entries.size() + k => k;
          rest -1 => rest;
        }
      }
      parent.send(P_Trigger, IntRef.make(entries[k] + rest*offs));
    }else{
      parent.send(P_Trigger, null);
    }
  },
  int entries[];
)


public class Mapper extends Moduck{
  fun static Mapper make(int entries[], int offsetPerPeriod){
    Mapper ret;
    OUT(P_Trigger);
    IN(TrigHandler, (entries));
    ret.addVal("offsetPerPeriod", offsetPerPeriod);
    return ret;
  }
}
