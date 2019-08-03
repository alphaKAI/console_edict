module cedict.avldict;
import cedict.dictionary;
import cedict.parser;
import cedict.avl;
import std.typecons;

class AVLDictionary : Dictionary {
  private AVLTree!(wstring, wstring) tree;

  this() {
    this.tree = new AVLTree!(wstring, wstring);
  }

  void insert(wstring key, wstring value) {
    this.tree.insert(key, value);
  }

  Nullable!wstring get(wstring key) {
    return this.tree.find(key);
  }

  bool exists(wstring key) {
    return this.tree.exists(key);
  }
}
