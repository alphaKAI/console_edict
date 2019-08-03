module cedict.dictionary;
import cedict.parser;
import std.typecons;

interface Dictionary {
  void insert(wstring key, wstring value);
  Nullable!wstring get(wstring key);
  bool exists(wstring key);
}

static Dictionary makeFromParseResults(DictType)(ParseResult[] results) {
  Dictionary dict = new DictType();

  foreach (ParseResult result; results) {
    dict.insert(result.head, result.desc);
  }

  return dict;
}
