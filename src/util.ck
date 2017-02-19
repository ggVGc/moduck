


public class Util{
  fun static dur bpmToDur(float bpm){
    return minute / bpm;
  }


  fun static int toSamples(dur d){
    return (d / samp) $ int;
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

  fun static IntRef whichNumber(string ch){
    for(0=>int x;x<10;x++){
      if(ch == ""+x){
        return IntRef.make(x);
      }
    }
    return null;
  }

  fun static SeqInfo seqFromString(string str, int beatSize, int seqLen){
    SeqInfo.make(str.length()) @=> SeqInfo ret;
    0 => int curBeatLen;
    0 => int count;
    0 => int totalLen;
    for(0=>int i;i<str.length();i++){
      whichNumber(str.substring(i, 1)) @=> IntRef num;
      if(num != null){
        num.i => ret.nums[count];
      }
      if(num != null || i == str.length()-1){
        curBeatLen + totalLen => totalLen;
        seqLen - totalLen => int restLen;
        if(restLen < 0){
          curBeatLen-restLen => ret.lens[count];
          1 +=> count;
          break;
        }else{
          curBeatLen => ret.lens[count];
          0 => curBeatLen;
          1 +=> count;
        }
      }
      beatSize + curBeatLen => curBeatLen;
    }
    
    ret.size(count);
    seqLen - totalLen => int restLen;
    if(restLen > 0){
      restLen + ret.lens[count-1] => ret.lens[count-1];
    }

    0 => int acc;
    for(0=> int i;i<ret.size();i++){
      ret.lens[i] +=> acc;
    }

    return ret;
  }


}

