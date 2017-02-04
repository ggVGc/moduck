
public class Util{
  fun static dur bpmToDur(float bpm){
    return minute / bpm;
  }

  fun static IntRef iref(int v){
    IntRef i;
    v => i.i;
    return i;
  }

  fun static Handler setVal(Handler target, string key, int v){
    Util.iref(v) @=> target.values[key];
    return target;
  }

}





