
include(pulses.m4)

class Connector{
  ChainData data;

  fun void preconnect(){
    data.srcTags.size() - data.targetTags.size() => int diff;
    for(0=>int i; i<diff;i++){
      data.targetTags << P_Default;
    }
    data.targetTags.size() - data.srcTags.size() => diff;
    for(0=>int i; i<diff;i++){
      data.srcTags << P_Default;
    }
  }

  fun ModuckP c(Moduck other){
    preconnect();
    return ModuckP.make(Patch.connect(other, data.srcTags, data.target, data.targetTags));
  }

  // Uses target as source and vice versa. Keeps srcTag and targetTag as is.
  fun ModuckP reverseConnect(Moduck other){
    preconnect();
    return ModuckP.make(Patch.connect(data.target, data.srcTags, other, data.targetTags));
  }

  fun Connector from(string v){
    data.srcTags << v;
    return this;
  }


  fun Connector to(string v){
    data.targetTags << v;
    return this;
  }

  fun Connector fromTo(string src, string dst){
    return from(src).to(dst);
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
    return b(Connector.make(m, [P_Default], [P_Default]));
  }

  fun ModuckP b(Connector con){
    con.c(this);
    return this;
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
    return ModuckP.make(Patch.remap(this, srcTag, dstTag));
  }

  // Repeat a signal that was received(and handled)
  fun ModuckP propagate(string tag){
    return ModuckP.make(Patch.propagate(this, tag));
  }

  // Repeat a received signal regardless if it was handled or not
  fun ModuckP thru(string tags[]){
    // TODO: Implement
    return this;
  }

  fun static ModuckP make(Moduck m){
    ModuckP ret;
    m._handlers @=> ret._handlers;
    m.handlerKeys @=> ret.handlerKeys;
    m._outs @=> ret._outs;
    m._outKeys @=> ret._outKeys;
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
