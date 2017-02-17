public class ModuckP extends Moduck{

  fun ModuckP c(string srcTag, Moduck other, string targetTag){
    return ModuckP.make(Patch.connect(this, srcTag, other, targetTag));
  }

  fun ModuckP c(Moduck other, string targetTag){
    return c(null, other, targetTag);
  }

  fun ModuckP c(Moduck other){
    return c(null, other, null);
  }

  fun ModuckP v(string srcTag, Moduck target, string targetValTag){
    return ModuckP.make(Patch.connVal(this, srcTag, target, targetValTag));
  }

  fun ModuckP v(Moduck target, string targetValTag){
    return v(null, target, targetValTag);
  }

  fun ModuckP multi(ChainData targets[]){
    return ModuckP.make(Patch.connectMulti(this, targets));
  }

  fun ModuckP chain(ChainData targets[]){
    return ModuckP.make(Patch.chain(this, targets));
  }

  fun ModuckP b(Moduck m){
    this.c(ModuckP.make(Patch.thru(m)));
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
}
