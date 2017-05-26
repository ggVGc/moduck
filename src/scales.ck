
public class Scales{
  static int Major[];
  static int MinorNatural[];
  static int MinorHarmonic[];

  fun static int[] fromChromatic(int scale[]){
    int ret[12];
    0 => int lastN;
    1 => int outInd;
    0 => ret[0];
    for(0=>int scaleInd;scaleInd<scale.size();++scaleInd){
      scale[scaleInd] => int n;
      for(0=>int i;i<n-lastN;++i){
        1 +=> outInd;
        scaleInd => ret[outInd];
      }
      n => lastN;
    }
    return ret;
  }
}

[0,2,4,5,7,9,11] @=> Scales.Major;
[0, 2, 3, 5, 7, 8, 10] @=> Scales.MinorNatural;
[0, 2, 3, 5, 7, 8, 11] @=> Scales.MinorHarmonic;


