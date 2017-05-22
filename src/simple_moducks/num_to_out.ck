
include(moduck_macros.m4)

genHandler(TrigHandler, P_Trigger, 
  MayInt lastVal;
  HANDLE{
    if(v != null){
      for(0=>int numInd;numInd<nums.size();++numInd){
        nums[numInd] @=> int n;
        if(v.i == n){
          parent.send(""+n, IntRef.yes());

          if(lastVal.valid){
            parent.send(""+lastVal.i, null);
          }

          lastVal.set(v.i);
          return;
        }

      }
    }
    if(lastVal.valid){
      parent.send(""+lastVal.i, null);
      lastVal.clear();
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
