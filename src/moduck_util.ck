
include(pulses.m4)

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

  /*
    fun static ModuckP update(ModuckP m, ModuckP processor){
      return update(m, P_Default, P_Default, processor);
    }
   */

}

