
class Connector{
  ChainData data;


  fun ModuckP c(Moduck other){
    return ModuckP.make(Patch.connect(other, data.srcTag, data.target, data.targetTag));
  }

  fun Connector from(string v){
    v @=> data.srcTag;
  }


  fun Connector to(string v){
    v @=> data.targetTag;
  }

  fun static Connector make(Moduck m, string fromTag, string toTag){
    Connector ret;
    ChainData.conn(fromTag, m, toTag) @=> ret.data;
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
    return Connector.make(this, null, null).c(other);
  }


  fun Connector cc(Moduck other){
    return c(other).from(null);
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

  fun ModuckP multi(Connector targets[]){
    ChainData datas[targets.size()];
    for(0=>int i; i<targets.size();i++){
      targets[i].data @=> datas[i];
    }
    return ModuckP.make(Patch.connectMulti(this, datas));
  }


  fun Connector from(string tag){
    return Connector.make(this, tag, null);
  }

  fun Connector to(string tag){
    return Connector.make(this, null, tag);
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
