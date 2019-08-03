module cedict.hashdict;

import cedict.dictionary;
import cedict.parser;
import cedict.avl;
import std.typecons;

class HashDictionary : Dictionary {
  private wstring[wstring] dict;
  private bool _ready;

  this() {
  }

  void insert(wstring key, wstring value) {
    if (!this._ready) {
      this._ready = true;
    }
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

  bool ready() {
    return this._ready;
  }
}
