module cedict.avldict;
import cedict.dictionary;
import cedict.parser;
import cedict.avl;
import std.typecons;

class AVLDictionary : Dictionary {
  private AVLTree!(wstring, wstring) tree;
  private bool _ready;

  this() {
    this.tree = new AVLTree!(wstring, wstring);
  }

  void insert(wstring key, wstring value) {
    if (!this._ready) {
      this._ready = true;
    }
    this.tree.insert(key, value);
  }

  Nullable!wstring get(wstring key) {
    return this.tree.find(key);
  }

  bool exists(wstring key) {
    return this.tree.exists(key);
  }

  bool ready() {
    return this._ready;
  }

  private wstring[] heads_cache;
  wstring[] getHeads() {
    if (heads_cache.length) {
      return heads_cache;
    }

    heads_cache = this.tree.keys;

    return heads_cache;
  }
}
