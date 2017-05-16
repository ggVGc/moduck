
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

  fun Connector from(int v){
    return from(""+v);
  }

  fun Connector from(string v){
    data.srcTags << v;
    return this;
  }

  fun Connector to(int v){
    return to(""+v);
  }

  fun Connector to(string v){
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

  fun ModuckP when(Moduck m){
    return when(m, P_Default);
  }

  fun ModuckP whenNot(Moduck m, string tag){
    return c(ModuckP.make(Repeater.make()).whenNot(m, tag).asModuck());
  } 

  fun ModuckP whenNot(Moduck m){
    return whenNot(m, P_Default);
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
  fun Connector to(ModuckP targetModuck, int dstTag){
    return to(targetModuck, ""+dstTag);
  }
  fun Connector to(ModuckP targetModuck){
    return to(targetModuck, P_Default);
  }
  fun ModuckP c(Moduck m){
    return m => ModuckP.make(Repeater.make()).from(srcTag).c;
  }

  fun ModuckP b(Moduck m){
    return c(Repeater.make()).b(m);
  }

}


class Conditional{
  ModuckP @ condM;
  string condTag;
  ModuckP @ thenM;
  Connector @ thenCon;
  Moduck @ parent;


  fun Conditional then(ModuckP m){
    m @=> thenM;
    return this;
  }
  fun Conditional then(Connector con){
    con @=> thenCon;
    return this;
  }

  fun void _setThen(ModuckP out){
    if(thenCon != null){
      (parent => thenCon.when(condM.asModuck(), condTag).c).asModuck() => out.c;
    }else{
      (parent => thenM.when(condM.asModuck(), condTag).c).asModuck() => out.c;
    }
  }


  fun ModuckP els(ModuckP elseM){
    ModuckP.make(Repeater.make()) @=> ModuckP out;
    _setThen(out);
    (parent => elseM.whenNot(condM.asModuck(), condTag).c).asModuck() => out.c;
    return ModuckP.make(Wrapper.make(parent, out.asModuck()));
  }


  fun ModuckP els(Connector elseCon){
    ModuckP.make(Repeater.make()) @=> ModuckP out;
    _setThen(out);
    (parent => elseCon.whenNot(condM.asModuck(), condTag).c).asModuck() => out.c;
    return ModuckP.make(Wrapper.make(parent, out.asModuck()));
  }


  fun static Conditional make(Moduck parent, ModuckP cond, string tag){
    Conditional ret;
    cond @=> ret.condM;
    tag => ret.condTag;
    parent @=> ret.parent;
    return ret;
  }
}


public class ModuckP extends Moduck{

  fun static ToConnector _from(int tag){
    return _from(""+tag);
  }

  fun static ToConnector _from(string tag){
    ToConnector ret;
    tag @=> ret.srcTag;
    return ret;
  }

  fun Conditional _iff(ModuckP m, string tag){
    return Conditional.make(this, m, tag);
  }

  fun Conditional _iff(ModuckP m, int tag){
    return _iff(m, ""+tag);
  }

  fun Conditional _iff(ModuckP m){
    return _iff(m, P_Default);
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


  fun ModuckP b(string fromTag, ModuckP m){
    return b(m.from(fromTag));
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

  fun ModuckP set(IntRef v){
    return set(P_Default, v);
  }

  fun ModuckP set(int v){
    return set(P_Default, v);
  }


  fun ModuckP multi(Connector targets[]){
    ChainData datas[targets.size()];
    for(0=>int i; i<targets.size();i++){
      ChainData.make(targets[i].data).balanceTags() @=> datas[i];
    }
    return ModuckP.make(Patch.connectMulti(this, datas));
  }

  fun Connector from(int tag){
    return from(""+tag);
  }

  fun Connector from(string tag){
    return Connector.make(this, [tag], null);
  }

  
  fun Connector to(int tag){
    return to(""+tag);
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

  fun ModuckP whenNot(Moduck m){
    return whenNot(m, P_Default);
  }

  fun ModuckP when(Moduck m, string tag){
    return ModuckP.make(Blocker.make()).hook(
      (m => ModuckP.make(Repeater.make()).from(tag).c).to(P_Gate)
    )
    => this.c;
  }

  fun ModuckP when(Moduck m){
    return when(m, P_Default);
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
