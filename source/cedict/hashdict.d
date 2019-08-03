module cedict.hashdict;

import cedict.dictionary;
import cedict.parser;
import cedict.avl;
import std.typecons;

class HashDictionary : Dictionary {
  private wstring[wstring] dict;

  this() {
  }

  void insert(wstring key, wstring value) {
    this.dict[key] = value;
  }

  Nullable!wstring get(wstring key) {
    if (key in this.dict) {
      return nullable(this.dict[key]);
    } else {
      return typeof(return).init;
    }
  }

  bool exists(wstring key) {
    return key in this.dict ? true : false;
  }
}
