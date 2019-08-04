module cedict.dictionary;
import cedict.parser;
import std.typecons;

interface Dictionary {
  bool ready();
  void insert(wstring key, wstring value);
  Nullable!wstring get(wstring key);
  bool exists(wstring key);
  wstring[] getHeads();
}

static Dictionary makeFromParseResults(DictType)(ParseResult[] results) {
  Dictionary dict = new DictType();

  foreach (ParseResult result; results) {
    dict.insert(result.head, result.desc);
  }

  return dict;
}
