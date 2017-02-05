
public class Mapper extends Moduck{

  int entries[];

  fun int handle(string tag, int v){
    getVal("offsetPerPeriod") => int offs;
    int k;
    int rest;
    if(v >= 0){
      v / entries.size() => rest;
      v % entries.size() => k;
    }else{
      v / entries.size() => rest;
      v % entries.size() => k;
      if(k < 0 ){
        entries.size() + k => k;
        rest -1 => rest;
      }
    }
    send(null, entries[k] + rest*offs);
    return true;
  }

  fun static Mapper make(int entries[], int offsetPerPeriod){
    Mapper ret;
    entries @=> ret.entries;
    ret.setVal("offsetPerPeriod", offsetPerPeriod);
    return ret;
  }
}
