
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


  // TODO: Reimplement these again if they are actually needed
  /* 
   fun static Moduck mul2(Moduck a, Moduck b){
     Multiplier.make(2) @=> Multiplier mult;
     Patch.connect(a, null, mult, "0");
     Patch.connect(b, null, mult, "1");
     samp => now;
     a.doHandle(P_Trigger, 0);
     b.doHandle(P_Trigger, 0);
     return mult;
   }

   fun static Moduck mul3(Moduck a, Moduck b, Moduck c){
     Multiplier.make(3) @=> Multiplier mult;
     Patch.connect(a, null, mult, "0");
     Patch.connect(b, null, mult, "1");
     Patch.connect(c, null, mult, "2");
     samp => now;
     a.doHandle(P_Trigger, 0);
     b.doHandle(P_Trigger, 0);
     c.doHandle(P_Trigger, 0);
     return mult;
   }


   fun static Moduck add2(Moduck a, Moduck b){
     Adder.make(2) @=> Adder add;
     Patch.connect(a, null, add, "0");
     Patch.connect(b, null, add, "1");
     samp => now;
     a.doHandle(P_Trigger, 0);
     b.doHandle(P_Trigger, 0);
     return add;
   }

   fun static Moduck mul3(Moduck a, Moduck b, Moduck c){
     Adder.make(3) @=> Adder add;
     Patch.connect(a, null, add, "0");
     Patch.connect(b, null, add, "1");
     Patch.connect(c, null, add, "2");
     samp => now;
     a.doHandle(P_Trigger, 0);
     b.doHandle(P_Trigger, 0);
     c.doHandle(P_Trigger, 0);
     return add;
   }
   */



  fun static ModuckP update(ModuckP m, string srcTag, string dstTag, ModuckP processor){
    // TODO: Default value always 0 here..
    ModuckP.make(Value.make(0)) @=> ModuckP val;
    m => val.fromTo(srcTag, "value").c;

    return Repeater.make()
      => val.c
      => processor.c
      => m.to(dstTag).c
    ;
  }


  fun static ModuckP update(ModuckP m, string dstTag, ModuckP processor){
    return update(m, recv(dstTag), dstTag, processor);
  }


  fun static ModuckP onlyHigh(){
    return ModuckP.make(Processor.make(NotEq.make(null), false));
  }

  fun static ModuckP onlyLow(){
    return ModuckP.make(Processor.make(Eq.make(null), false))
           => ModuckP.make(Inverter.make(0)).c;
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
      ModuckP.make(Toggler.make(initiallyOn)) @=> ModuckP toggl;
      ret => toggl.fromTo(recv(tag), P_Toggle).c;
      toggl => src.to(tag).c;
    }
    return ret;
  }


  /*
    fun static ModuckP update(ModuckP m, ModuckP processor){
      return update(m, P_Default, P_Default, processor);
    }
   */

}

