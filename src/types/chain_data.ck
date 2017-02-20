
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
      srcTags @=> ret.srcTags;
    }
    if(targetTags != null){
      targetTags @=> ret.targetTags;
    }
    return ret;
  }

  fun static ChainData make(string srcTag, Moduck target, string targetTag){
    return make([srcTag], target, [targetTag]);
  }

}
