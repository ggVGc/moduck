
include(pulses.m4)

class Connector{
  ChainData data;
  null @=> string _triggerName;
  null @=> IntRef _triggerVal;

  fun ModuckP c(Moduck other){
    data.balanceTags();
    Patch.connect(other, data.srcTags, data.target, data.targetTags) @=> Moduck ret;
    if(_triggerName != null){
      samp => now;
      other.doHandle(_triggerName, _triggerVal);
    }
    return ModuckP.make(ret);
  }

  // Uses target as source and vice versa. Keeps srcTag and targetTag as is.
  fun ModuckP reverseConnect(Moduck other){
    data.balanceTags();
    Patch.connect(data.target, data.srcTags, other, data.targetTags) @=> Moduck ret;
    if(_triggerName != null){
      samp => now;
      data.target.doHandle(_triggerName, _triggerVal);
    }
    return ModuckP.make(ret);
  }

  fun Connector trigger(string tag, IntRef val){
    tag @=> _triggerName;
    val @=> _triggerVal;
    return this;
  }


  fun Connector trigger(string tag){
    return trigger(tag, IntRef.make(0));
  }

  fun Connector trigger(){
    return trigger(P_Default);
  }

  fun Connector from(string v){
    // <<<"from, ", v>>>;
    data.srcTags << v;
    return this;
  }

  fun Connector to(string v){
    // <<<"to, ", v>>>;
    data.targetTags << v;
    return this;
  }

  fun Connector fromTo(string src, string dst){
    data.balanceTags();
    // <<<"Fromto, ", src, dst>>>;
    return from(src).to(dst);
  }

  fun Connector listen(string tag){
    return fromTo(tag, tag);
  }

  fun Connector listen(string tags[]){
    for(0=>int elemInd;elemInd<tags.size();++elemInd){
      tags[elemInd] @=> string tag;
      listen(tag);
    }
    return this;
  }

  fun ModuckP when(Moduck m, string tag){
    return c(ModuckP.make(Repeater.make()).when(m, tag).asModuck());
  } 

  fun ModuckP whenNot(Moduck m, string tag){
    return c(ModuckP.make(Repeater.make()).whenNot(m, tag).asModuck());
  } 

  fun static Connector make(Moduck m, string fromTags[], string dstTags[]){
    Connector ret;
    ChainData.make(fromTags, m, dstTags) @=> ret.data;
    return ret;
  }
}

class ToConnector{
  string srcTag;
  fun Connector to(ModuckP targetModuck, string dstTag){
    return targetModuck.fromTo(srcTag, dstTag);
  }
  fun Connector to(ModuckP targetModuck){
    return to(targetModuck, P_Default);
  }
  fun ModuckP c(Moduck m){
    return m => ModuckP.make(Repeater.make()).from(srcTag).c;
  }
}


class Conditional{
  ModuckP @ condM;
  string condTag;
  ModuckP @ thenM;
  Connector @ thenCon;

  fun Conditional then(ModuckP m){
    m @=> thenM;
    return this;
  }
  fun Conditional then(Connector con){
    con @=> thenCon;
    return this;
  }

  fun ModuckP _setThen(ModuckP rep){
    if(thenCon != null){
      return rep.b(thenCon.when(condM.asModuck(), condTag).asModuck());
    }else{
      return rep.b(thenM.when(condM.asModuck(), condTag).asModuck());
    }
  }


  fun ModuckP els(ModuckP elseM){
    ModuckP.make(Repeater.make()) @=> ModuckP ret;
    _setThen(ret);
    return ret.b(elseM.whenNot(condM.asModuck(), condTag).asModuck());
  }


  fun ModuckP els(Connector elseCon){
    ModuckP.make(Repeater.make()) @=> ModuckP ret;
    _setThen(ret);
    return ret.b(elseCon.whenNot(condM.asModuck(), condTag).asModuck());
  }


  fun static Conditional make(ModuckP cond, string tag){
    Conditional ret;
    cond @=> ret.condM;
    tag => ret.condTag;
    return ret;
  }
}


public class ModuckP extends Moduck{

  fun static ToConnector _from(string tag){
    ToConnector ret;
    tag @=> ret.srcTag;
    return ret;
  }

  fun static Conditional _iff(ModuckP m, string tag){
    return Conditional.make(m, tag);
  }

  fun ModuckP c(Moduck other){
    return Connector.make(this, [P_Default], [P_Default]).c(other);
  }

  fun Connector cc(Moduck other){
    return c(other).from(P_Default);
  }

  fun ModuckP b(Moduck m){
    return b(Connector.make(m, [P_Default], [P_Default]));
  }

  fun ModuckP b(Connector con){
    con.c(this);
    return this;
  }

  fun ModuckP set(string tag, IntRef v){
    setVal(tag, v);
    return this;
  }

  fun ModuckP set(string tag, int v){
    setVal(tag, v);
    return this;
  }

  fun ModuckP multi(Connector targets[]){
    ChainData datas[targets.size()];
    for(0=>int i; i<targets.size();i++){
      ChainData.make(targets[i].data).balanceTags() @=> datas[i];
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

  fun ModuckP whenNot(Moduck m, string tag){
    ModuckP.make(Blocker.make()) @=> ModuckP blk;
    blk.doHandle(P_Gate, IntRef.yes());
    return blk.hook(
      (m => ModuckP.make(Inverter.make()).from(tag).c).to(P_Gate)
    )
    => this.c;
  }

  fun ModuckP when(Moduck m, string tag){
    return ModuckP.make(Blocker.make()).hook(
      (m => ModuckP.make(Repeater.make()).from(tag).c).to(P_Gate)
    )
    => this.c;
  }

  fun static ModuckP make(Moduck m){
    ModuckP ret;
    m._handlers @=> ret._handlers;
    m.handlerKeys @=> ret.handlerKeys;
    m._outs @=> ret._outs;
    m._outKeys @=> ret._outKeys;
    m._valHandlers@=> ret._valHandlers;
    m._valHandlerKeys@=> ret._valHandlerKeys;
    m.name @=> ret.name;
    return ret;
  }

  fun static ModuckP[] many(Moduck list[]){
    ModuckP ret[list.size()];
    for(0=>int i;i<list.size();++i){
      ModuckP.make(list[i]) @=> ret[i];
    }
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

  fun ModuckP setName(string n){
    n @=> name;
    return this;
  }

  fun Moduck asModuck(){
    return this;
  }

  fun ModuckP persist(string fileName){
    doPersist("../vals/"+fileName);
    return this;
  }

}
