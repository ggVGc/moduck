
include(pulses.m4)

public class MUtil{

  fun static Moduck[] castModuckList(ModuckP list[]){
    Moduck out[list.size()];
    for(0=>int i;i<list.size();i++){
      list[i] @=> out[i];
    }
    return out;
  }


  fun static ModuckP _combine(Moduck children[]){
    Repeater.make() @=> Repeater in;
    Repeater.make() @=> Repeater out;
    
    for(0=>int i;i<children.size();i++){
      Patch.connect(in, null, children[i], null);
      Patch.connect(children[i], null, out, null);
    }

    return ModuckP.make(Wrapper.make(in, out));
  }

  fun static ModuckP _combine(ModuckP children[]){
    return _combine(castModuckList(children));
  }



  /*
    fun static ModuckP remap(Moduck src, string srcTag, string dstTag){
      Util.copy(src.outKeys) @=> string keys[];
      if(!Util.contains(dstTag, keys)){
        keys << dstTag;
      }

      ModuckP.make(Repeater.make(keys)) @=> ModuckP out;
      for(0=>int i; i<src.outKeys.size();i++){
        src.outKeys[i] @=> string k;
        if(k != dstTag){


          <<< k>>>;
          this => out.listen(k).c;
        }
      }
    }
   */


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

}

