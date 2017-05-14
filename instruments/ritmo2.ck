fun ModuckP ritmo2(ModuckP children[]){

   ["asdsad"] @=> string rootTags[];
   def(root, mk(Repeater, rootTags));

   def(out, mk(Repeater,
       Util.concatStrings([
         [P_Trigger]
         /* ,Util.numberedStrings("active_", Util.range(0, rhythms.size()-1)) */
       ])));

  /* 
   Util.concatStrings([
     [P_Clock, P_Reset,P_Hold]
     ,extraTags
     ,Util.prefixStrings("active_", extraTags)
     ,Util.numberedStrings("", Util.range(0, rhythms.size()-1))
   ])
     @=> string rootTags[];

   for(0=>int rhythmInd;rhythmInd<rhythms.size();++rhythmInd){
     rhythms[rhythmInd] @=> ModuckP rh;
     for(0=>int tagInd;tagInd<extraTags.size();++tagInd){
       extraTags[tagInd] @=> string tag;
       root => rh.listen(tag).c;
     }
   }

   def(holdBlocker, mk(Blocker));
   root => holdBlocker.fromTo(P_Hold, P_Gate).c;
   holdBlocker.doHandle(P_Gate, IntRef.make(0));

   if(individualMode){
     individualsChain(rhythms, root, out, extraTags);
   }else{
     combinedChain(rhythms, root, out, extraTags, holdBlocker);
   }


   */
   return mk(Wrapper, root, out);
}
