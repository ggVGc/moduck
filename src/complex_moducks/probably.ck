

class ProbablyFun extends IntFun{
  fun IntRef call(int v){
Math.randomf() @=> float x;
    if(Math.randomf()*100 <= parent.getVal("chance")){
      return IntRef.make(v);
    }else{
      return null;
    }
  }
}

public class Probably{
  // Chance in percentage, between 0 and 100
  fun static Processor make(int chance){
    ProbablyFun f;
    Processor.make(f) @=> Processor ret;
    ret.addVal("chance", chance);
    return ret;
  }

  fun static Moduck[] many(int count, int chance){
    Moduck ret[count];
    for(0=>int x;x<count;++x){
      make(chance) @=> ret[x];
    }
    return ret;
  }
}
