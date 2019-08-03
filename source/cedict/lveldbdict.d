module cedict.lveldbdict;

import cedict.dictionary;
import cedict.parser;
import cedict.avl;
import std.format;
import std.typecons;
import leveldb;

enum LEVELDB_DB_NAME = "cedict_leveldb";
enum LEVELDB_SPECIAL_INITIALIZED_MARKER = "__LEVELDB_DICTIONARY_IS_INITIALIZED";

class LevelDBDictionary : Dictionary {
  private DB db;
  private bool _ready;

  this() {
    auto opt = new Options;
    opt.create_if_missing = true;

    this.db = new DB(opt, LEVELDB_DB_NAME);
    if (this.db.get_slice(LEVELDB_SPECIAL_INITIALIZED_MARKER).ok) {
      this._ready = true;
    }
  }

  bool ready() {
    if (!this._ready) {
      this._ready = this.db.get_slice(LEVELDB_SPECIAL_INITIALIZED_MARKER).ok;
    }

    return this._ready;
  }

  import std.stdio;
  import std.conv;

  void insert(wstring key, wstring value) {
    if (!this.ready) {
      this.db.put(LEVELDB_SPECIAL_INITIALIZED_MARKER, true);
    }

    this.db.put(key.to!string, value.to!string);
  }

  Nullable!wstring get(wstring key) {
    auto ret = this.db.get_slice(key.to!string);

    if (ret.ok) {
      import std.conv;

      return ret.as!string
        .to!wstring
        .nullable;
    } else {
      return typeof(return).init;
    }
  }

  bool exists(wstring key) {
    return this.db.get_slice(key).ok;
  }
}
