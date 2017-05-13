
include(macros.m4)

genHandler(TrigHandler, P_Trigger, 
  IntRef lastVal;
  HANDLE{
    if(v != null){
      for(0=>int numInd;numInd<nums.size();++numInd){
        nums[numInd] @=> int n;
        if(v.i == n){
          parent.send(""+n, IntRef.yes());
          IntRef.make(n) @=> lastVal;
          return;
        }

      }
    }
    if(lastVal != null){
      parent.send(""+lastVal.i, null);
      null @=> lastVal;
    }
    parent.send(P_Trigger, null);
  },
  int nums[];
)


public class NumToOut extends Moduck{
  fun static NumToOut make(int nums[]){
    NumToOut ret;
    OUT(P_Trigger);
    for(0=>int numInd;numInd<nums.size();++numInd){
      nums[numInd] @=> int n;
      OUT(""+n);
    }
    IN(TrigHandler, (nums));
    return ret;
  }

}
