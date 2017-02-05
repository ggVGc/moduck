
public class Util{
  fun static dur bpmToDur(float bpm){
    return minute / bpm;
  }


  fun static IntRef toSamples(dur d){
    return IntRef.make((d / samp) $ int);
  }

  fun static string strOrNull(string s){
    if(s != null){
      return s;
    }else{
      return "nil";
    }
  }

  fun static int[] range(int start, int end, int step){
    int smallest;
    int biggest;
    if(start > end){
      start => biggest;
      end => smallest;
      -Std.abs(step) => step;
    }else{
      end => biggest;
      start => smallest;
      Std.abs(step) => step;
    }

    (biggest - smallest / step $ float) $ int + 1 => int sz;
    int arr[sz];

    for(0 => int i; i<sz; i++){
      start + step*i => arr[i];
    }

    return arr;
  }

  fun static int[] concat(int lists[][]){
    0 => int sz;
    for(0 => int i; i<lists.size(); i++){
      sz + lists[i].size() => sz;
    }
    int arr[sz];
    0 => int count;
    for(0 => int i; i<lists.size(); i++){
      for(0 => int j; j<lists[i].size(); j++){
        lists[i][j] => arr[count];
        count+1 => count;
      }
    }
    return arr;
  }


  fun static int[] ratios(int min, int max, float ratios[]){
    int arr[ratios.size()];
    for(0 => int i; i<ratios.size(); i++){
      max - min => float delta;
      ratios[i] => float r;
      if(r < 0 || r > 1){
        <<<"Error: ratio out of range" >>>;
      }
      (min + r * delta ) $ int => arr[i];
    }
    return arr;
  }
}





