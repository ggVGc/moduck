
public class ChainData{
  string srcTag;
  Moduck @ target;
  string targetTag;
  int isValConnection;


  fun static ChainData conn(string srcTag, Moduck target, string targetTag){
    ChainData ret;
    srcTag => ret.srcTag;
    target @=> ret.target;
    targetTag => ret.targetTag;
    false => ret.isValConnection;
    return ret;
  }

  fun static ChainData val(string srcTag, Moduck target, string targetTag){
    ChainData ret;
    srcTag => ret.srcTag;
    target @=> ret.target;
    targetTag => ret.targetTag;
    true => ret.isValConnection;
    return ret;
  }

}
