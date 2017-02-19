public class SeqInfo{
  int lens[0];
  int nums[0];

  fun int size(int newSize){
    nums.size(newSize-1);
    return lens.size(newSize);
  }

  fun int size(){
    return lens.size();
  }

  fun static SeqInfo make(int sz){
    SeqInfo ret;
    ret.size(sz);
    return ret;
  }
}


