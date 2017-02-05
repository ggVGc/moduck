
public class ChainData{
  string srcTag;
  Moduck @ target;
  string targetTag;
  int type;


  fun static ChainData conn(string srcTag, Moduck target, string targetTag){
    ChainData ret;
    srcTag => ret.srcTag;
    target @=> ret.target;
    targetTag => ret.targetTag;
    1 => ret.type;
    return ret;
  }

  fun static ChainData val(string srcTag, Moduck target, string targetTag){
    ChainData ret;
    srcTag => ret.srcTag;
    target @=> ret.target;
    targetTag => ret.targetTag;
    2 => ret.type;
    return ret;
  }

}
