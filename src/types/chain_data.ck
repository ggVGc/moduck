
include(pulses.m4)

public class ChainData{
  Moduck @ target;
  string srcTags[0];
  string targetTags[0];


  fun static ChainData make(string srcTags[], Moduck target, string targetTags[]){
    ChainData ret;
    /*
      if(srcTags != null){
        for(0=>int i;i<srcTags.size();++i){
          ret.srcTags << srcTags[i];
        }
      }
      if(targetTags != null){
        for(0=>int i;i<targetTags.size();++i){
          ret.targetTags << targetTags[i];
        }
      }
     */
    target @=> ret.target;
    if(srcTags != null){
      Util.copy(srcTags) @=> ret.srcTags;
    }
    if(targetTags != null){
      Util.copy(targetTags) @=> ret.targetTags;
    }
    return ret;
  }

  fun ChainData balanceTags(){
    srcTags.size() - targetTags.size() => int diff;
    for(0=>int i; i<diff;i++){
      targetTags << P_Default;
    }
    targetTags.size() - srcTags.size() => diff;
    for(0=>int i; i<diff;i++){
      srcTags << P_Default;
    }
    return this;
  }

  fun static ChainData make(string srcTag, Moduck target, string targetTag){
    return make([srcTag], target, [targetTag]);
  }
  fun static ChainData make(ChainData other){
    return make(Util.copy(other.srcTags), other.target, Util.copy(other.targetTags));
  }

}
