
include(pulses.m4)

class Connector{
  ChainData data;

  fun ModuckP c(Moduck other){
    // <<< data.srcTags[0], data.targetTags[0] >>>;
    data.srcTags.size() - data.targetTags.size() => int diff;
    for(0=>int i; i<diff;i++){
      data.targetTags << P_Default;
    }
    data.targetTags.size() - data.srcTags.size() => diff;
    for(0=>int i; i<diff;i++){
      data.srcTags << P_Default;
    }
    return ModuckP.make(Patch.connect(other, data.srcTags, data.target, data.targetTags));
  }

  // Uses target as source and vice versa. Keeps srcTag and targetTag as is.
  fun ModuckP reverseConnect(Moduck other){
    return ModuckP.make(Patch.connect(data.target, data.srcTags, other, data.targetTags));
  }

  fun Connector from(string v){
    data.srcTags << v;
    return this;
  }


  fun Connector to(string v){
    <<< "TO", v>>>;
    <<<data.targetTags.size()>>>;
    data.targetTags << v;
    <<<data.targetTags.size()>>>;
    return this;
  }

  fun static Connector make(Moduck m, string fromTags[], string dstTags[]){
    Connector ret;
    ChainData.make(fromTags, m, dstTags) @=> ret.data;
    return ret;
  }
}


public class ModuckP extends Moduck{
  /*
    fun ModuckP connect(string srcTag, Moduck other, string targetTag){
      return ModuckP.make(Patch.connect(this, srcTag, other, targetTag));
    }


  fun ModuckP connect(string srcTag, Moduck other, string targetTag){
    return ModuckP.make(Patch.connect(this, srcTag, other, targetTag));
  }

  fun ModuckP c(string srcTag, Moduck other, string targetTag){
    return connect(srcTag, other, targetTag);
  }

  fun ModuckP c(Moduck other, string targetTag){
    return c(null, other, targetTag);
  }
   */

  /*
    fun ModuckP connect(Moduck other){
      return Connector.make(this, null, null).c(other);
    }
   */


  fun ModuckP c(Moduck other){
    return Connector.make(this, [P_Default], [P_Default]).c(other);
  }


  fun Connector cc(Moduck other){
    return c(other).from(P_Default);
  }

  /*
    fun ModuckP c(Connector con){
      Repeater.make() @=> Repeater rep;
      return gt
    }
   */


  /*
    fun ModuckP multi(ChainData targets[]){
      return ModuckP.make(Patch.connectMulti(this, targets));
    }
   */

  /*
    fun ModuckP chain(ChainData targets[]){
      return ModuckP.make(Patch.chain(this, targets));
    }
   */

  fun ModuckP b(Moduck m){
    Patch.connect(this, P_Default, Patch.thru(m), P_Default);
    return this;
  }

  fun ModuckP b(Connector con){
    return b(con.c(Repeater.make()));
  }

  fun ModuckP set(string tag, int v){
    setVal(tag, v);
    return this;
  }

  fun ModuckP multi(Connector targets[]){
    ChainData datas[targets.size()];
    for(0=>int i; i<targets.size();i++){
      targets[i].data @=> datas[i];
    }
    return ModuckP.make(Patch.connectMulti(this, datas));
  }


  fun Connector from(string tag){
    return Connector.make(this, [tag], null);
  }


  fun Connector to(string tag){
    return Connector.make(this, null, [tag]);
  }

  fun Connector listen(string tags[]){
    return Connector.make(this, tags, tags);
  }

  fun Connector listen(string tag){
    return listen([tag]);
  }

  fun Connector fromTo(string src, string dst){
    return Connector.make(this, [src], [dst]);
  }


  // Attach to other signal without interfering with current chain
  fun ModuckP hook(Connector con){
    con.reverseConnect(this);
    return this;
  }

  // Translate one output tag into another
  fun ModuckP map(string srcTag, string dstTag){
    Util.copy(this.outKeys) @=> string keys[];

    if(!Util.contains(dstTag, keys)){
      keys << dstTag;
    }
    

    ModuckP.make(Repeater.make(keys)) @=> ModuckP ret;
    // this => ret.from(srcTag).to(dstTag).c;
    this => ret.from(srcTag).to(dstTag).c;
    return ModuckP.make(Wrapper.make(this, ret));
  }

  // Repeat a signal that was received(and handled)
  fun ModuckP propagate(string tag){
    // TODO: Implement
    return map(recv(tag), tag);
  }

  // Repeat a received signal regardless if it was handled or not
  fun ModuckP thru(string tags[]){
    // TODO: Implement
    return this;
  }

  fun static ModuckP make(Moduck m){
    ModuckP ret;
    m.values @=> ret.values;
    m.handlers @=> ret.handlers;
    m.handlerKeys @=> ret.handlerKeys;
    m.outs @=> ret.outs;
    m.outKeys @=> ret.outKeys;
    return ret;
  }

  /*
    fun static Connector From(string tag){
      return Connector.make(null, tag, null);
    }

    fun static Connector To(string tag){
      return Connector.make(null, null, tag);
    }
   */

}
