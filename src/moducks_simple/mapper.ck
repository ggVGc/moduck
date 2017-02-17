
include(macros.m4)

genHandler(TrigHandler, P_Trigger,
  HANDLE{
    parent.getVal("offsetPerPeriod") => int offs;
    int k;
    int rest;
    if(v >= 0){
      v / entries.size() => rest;
      v % entries.size() => k;
    }else{
      v / entries.size() => rest;
      v % entries.size() => k;
      if(k < 0 ){
        entries.size() + k => k;
        rest -1 => rest;
      }
    }
    parent.send(P_Trigger, entries[k] + rest*offs);
  },
  int entries[];
)


public class Mapper extends Moduck{
  fun static Mapper make(int entries[], int offsetPerPeriod){
    Mapper ret;
    ret.setVal("offsetPerPeriod", offsetPerPeriod);
    OUT(P_Trigger);
    IN(TrigHandler, (entries));
    return ret;
  }
}
