include(pulses.m4)

public class Patch{
  fun static void connectLoop(Moduck src, string srcEventName, Moduck target, string targetEventName){
    while(true){
      src.getOut(srcEventName) @=> VEvent ev;
      /*
        if(target.getOut(targetEventName) == null){
          <<<"Invalid target event"+target.name+", "+target+":"+targetEventName>>>;
        }
       */
      if(ev == null){
        <<<"Null event from "+src.name+", "+src+":"+srcEventName>>>;
        <<<Util.catStrings(src._outKeys)>>>;
      }
      ev => now;
      target.doHandle(targetEventName, ev.val);
    }
  }


  fun static Moduck propagate(Moduck src, string tag){
    filterNonRecvPulses(src.handlerKeys) @=> string srcKeys[];
    Repeater.make(srcKeys) @=> Repeater parent;
    filterNonRecvPulses(src._outKeys) @=> string outKeys[];
    if(!Util.contains(tag, outKeys)){
      outKeys << tag;
    }
    Repeater.make(outKeys) @=> Repeater out;

    for(0=>int i; i<srcKeys.size();i++){
      srcKeys[i] @=> string k;
      Patch.connect(parent, k, src, k);
    }

    for(0=>int i; i<src._outKeys.size();i++){
      src._outKeys[i] => string k;
      if(!isRecvPulse(k)){
        if(k != tag){
          Patch.connect(src, k, out, k);
        }
      }
    }
    Patch.connect(parent, recv(tag), out, tag);

    return Wrapper.make(parent, out);
  }


  fun static Moduck remap(Moduck src, string srcTag, string dstTag){
    filterNonRecvPulses(src.handlerKeys) @=> string keys[];

    if(!Util.contains(dstTag, keys)){
      keys << dstTag;
    }
    
    Repeater.make(keys) @=> Moduck out;
    connect(src, srcTag, out, dstTag);

    for(0=>int i; i<keys.size();i++){
      keys[i] @=> string k;
      if(k != srcTag && k != dstTag){
        connect(src, k, out, k);
      }
    }
    return Wrapper.make(src, out);
  }



  fun static Moduck connect(Moduck src, Moduck target){
    return connect(src, null, target, null);
  }


  fun static Moduck connect(Moduck src, string srcTag, Moduck target, string targetTag){
    return connect(src, [srcTag], target, [targetTag]);
  }


  fun static Moduck connect(Moduck src, string srcEventNames[], Moduck target, string targetEventNames[]){
    if(srcEventNames == null){
      [P_Default] @=> srcEventNames;
    }
    if(targetEventNames == null){
      [P_Default] @=> targetEventNames;
    }
    if(src._outKeys.size() == 0){
      <<<"Error: No source outputs:"+src>>>;
    }

    if(target.handlerKeys.size() == 0){
      <<<"Error: No target inputs:"+target>>>;
    }

    if(srcEventNames.size() != targetEventNames.size()){
      <<< "Inequal event tag counts">>>;
      <<<"Source tags:", Util.catStrings(srcEventNames) >>>;
      <<<"Target tags:", Util.catStrings(targetEventNames) >>>;
      Machine.crash();
    }

    for(0 => int i; i<srcEventNames.size(); i++){
      srcEventNames[i] => string srcTag;
      targetEventNames[i] => string dstTag;

      filterNonRecvPulses(src._outKeys) @=> string nonRecvs[];
      if(nonRecvs.size() == 0){
        // Tried connecting to source with no outputs
        // This is okay, and is currently used for Blackhole
        return src;
      }

      spork ~ connectLoop(src, srcTag, target, dstTag);
    }
    return Wrapper.make(src, target);
  }


  fun static Moduck chain(Moduck first, ChainData rest[]){
    first @=> Moduck h;
    for(0 => int i; i<rest.size(); i++){
      rest[i] @=> ChainData d;
      connect(h, d.srcTags, d.target, d.targetTags) @=> h;
    }
    return Wrapper.make(first, h);
  }

  fun static Moduck connectMulti(Moduck src, ChainData targets[]){
    string allOutKeys[0];

    for(0 => int i; i<targets.size(); i++){
      targets[i] @=> ChainData d;
      for(0 => int k; k<d.target._outKeys.size(); k++){
        d.target._outKeys[k] @=> string tag;
        if(!isRecvPulse(tag) && !Util.contains(tag, allOutKeys)){
          allOutKeys << tag;
        }
      }
    }

    Repeater.make(allOutKeys) @=> Repeater out;
    for(0 => int i; i<targets.size(); i++){
      targets[i] @=> ChainData d;
      connect(src, d.srcTags, d.target, d.targetTags);
      for(0 => int k; k<d.target._outKeys.size(); k++){
        d.target._outKeys[k] @=> string tag;
        if(!isRecvPulse(tag)){
          connect(d.target, tag, out, tag);
        }
      }
    }

    return Wrapper.make(src, out);
  }

  fun static Moduck thru(Moduck other){
    Repeater.make() @=> Repeater inp;
    Delay.make(samp) @=> Delay out;
    Patch.connectMulti(inp, [
      ChainData.make([P_Default], other, [P_Default])
      ,ChainData.make([P_Default], out, [P_Default])
    ]);
    return Wrapper.make(inp, out);
  }

}
