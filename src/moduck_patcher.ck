
class Connector{
  Moduck @ target;
  string fromTag;
  string toTag;
  int isMulti;

  fun ModuckP connect(Moduck other){
    return ModuckP.make(Patch.connect(other, fromTag, target, toTag));
  }

  fun ModuckP c(Moduck other){
    return connect(other);
  }

  fun Connector from(string v){
    v @=> fromTag;
  }


  fun Connector to(string v){
    v @=> toTag;
  }

  fun static Connector make(Moduck m, int isMulti, string fromTag, string toTag){
    Connector ret;
    fromTag @=> ret.fromTag;
    toTag @=> ret.toTag;
    m @=> ret.target;
    isMulti => ret.isMulti;
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
      return Connector.make(this, false, null, null).connect(other);
    }
   */


  fun ModuckP c(Moduck other){
    return Connector.make(this, false, null, null).connect(other);
  }

  /*
    fun ModuckP c(Connector con){
      Repeater.make() @=> Repeater rep;
      return gt
    }
   */

  fun ModuckP v(string srcTag, Moduck target, string targetValTag){
    return ModuckP.make(Patch.connVal(this, srcTag, target, targetValTag));
  }

  fun ModuckP v(Moduck target, string targetValTag){
    return v(null, target, targetValTag);
  }

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

  fun ModuckP branch(Moduck m){
    Patch.connect(this, null, Patch.thru(m), null);
    return this;
  }

  fun ModuckP b(Moduck m){
    return branch(m);
  }

  fun ModuckP set(string tag, int v){
    setVal(tag, v);
    return this;
  }

  /*
    fun ModuckP mult(Moduck other){
      return ModuckP.make(Patch.connectMulti(this, [ChainData.conn(null, other, null)]));
    }
    fun ModuckP m(Moduck other){return mult(other);}
   */


  fun Connector from(string tag){
    return Connector.make(this, false, tag, null);
  }

  fun Connector to(string tag){
    return Connector.make(this, false, null, tag);
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
      return Connector.make(null, false, tag, null);
    }

    fun static Connector To(string tag){
      return Connector.make(null, false, null, tag);
    }
   */

}
