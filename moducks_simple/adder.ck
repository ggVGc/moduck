
public class Adder extends Moduck{
  int inputCount;

  fun int handle(string tag, int v){
    if(tag == "" || tag == Pulse.Trigger()){
      0 => int acc;
      for(0 => int i; i<inputCount; i++){
        acc + getVal(""+i) => acc;
      }
      send(null, acc);
      return true;
    }

    for(0 => int i; i<inputCount; i++){
      if(""+i == tag){
        setVal(""+i, v);
        return true;
      }
    }

    return false;
  }

  fun static Adder make(int inputs){
    Adder ret;
    inputs => ret.inputCount;
    for(0 => int i; i<inputs; i++){
      ret.setVal(""+i, 1);
    }
    return ret;
  }
}

