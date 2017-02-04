
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


  fun static Handler setValRef(Handler target, string key, IntRef v){
    v @=> target.values[key];
    return target;
  }

  fun static IntRef toSamples(dur d){
    return Util.iref((d / samp) $ int);
  }

  fun static string strOrNull(string s){
    if(s != null){
      return s;
    }else{
      return "null";
    }
  }
}





