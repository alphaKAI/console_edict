module cedict.parser;
import std.stdio;

struct ParseResult {
  wstring head;
  wstring desc;
}

interface DictParser {
  ParseResult[] parseFile(File fp);
}
