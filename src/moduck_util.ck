
include(pulses.m4)
include(funcs.m4)

public class MUtil{

  fun static Moduck[] castModuckList(ModuckP list[]){
    Moduck out[list.size()];
    for(0=>int i;i<list.size();i++){
      list[i] @=> out[i];
    }
    return out;
  }


  fun static ModuckP combine(Moduck children[]){
    string allSrcKeys[0];

    for(0 => int i; i<children.size(); i++){
      children[i] @=> Moduck child;
      for(0 => int k; k<child.handlerKeys.size(); k++){
        child.handlerKeys[k] @=> string tag;
        if(!isRecvPulse(tag) && !Util.contains(tag, allSrcKeys)){
          allSrcKeys << tag;
        }
      }
    }

    ChainData datas[0];
    for(0 => int i; i<children.size(); i++){
      ChainData.make(null, children[i], null) @=> ChainData d;
      for(0 => int k; k<d.target.handlerKeys.size(); k++){
        d.target.handlerKeys[k] @=> string tag;
        if(!isRecvPulse(tag)){
          d.srcTags << tag;
          d.targetTags << tag;
        }
        datas << d;
      }
    }

    Repeater.make(allSrcKeys) @=> Repeater root;

    return ModuckP.make(Patch.connectMulti(root, datas));
  }

  fun static ModuckP combine(ModuckP children[]){
    return combine(castModuckList(children));
  }


  fun static ModuckP passThrough(ModuckP src, string ignoreTags[]){
    src.getSourceTags() @=> string origTags[];
    ModuckP.make(Repeater.make(origTags)) @=> ModuckP in;
    for(0=>int tagInd;tagInd<origTags.size();++tagInd){
      origTags[tagInd] @=> string tag;
      if(!Util.contains(tag, ignoreTags)){
        in => src.listen(tag).c;
      }else{
        in => ModuckP.make(Blackhole.make()).from(tag).c;
      }
    }
    return ModuckP.make(Wrapper.make(in, src));
  }



  fun static ModuckP gatesToToggles(ModuckP src, string tags[], int initiallyOn){
    passThrough(src, tags) @=> ModuckP ret;
    for(0=>int tagInd;tagInd<tags.size();++tagInd){
      tags[tagInd] @=> string tag;
      ModuckP.make(Toggler.make(initiallyOn)) @=> ModuckP tog;
      ret => tog.fromTo(recv(tag), P_Toggle).c;
      tog => src.to(tag).c;
    }
    return ret;
  }



}

