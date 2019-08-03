module cedict.eijiroparser;

/*
 * This is a parser implementation of Eijiro format.  
 * This code is mostly ported to D from https://github.com/wtetsu/mouse-dictionary/blob/master/src/options/logic/eijiroparser.js
 * Original License: MIT LICENSE
 * Original Copyright: Copyright 2018-present wtetsu
*/

import cedict.parser;
import std.typecons;
import std.string;
import std.stdio;
import std.conv;

private enum DELIM1 = " : ";
private enum DELIM2 = "  {";

class EijiroParser : DictParser {
  wstring[] lines;
  wstring currentHead;

  ParseResult[] parseFile(File fp) {
    ParseResult[] results;
    foreach (_line; fp.byLine) {
      wstring line = _line.to!wstring;
      auto ret = this.addLine(line);
      if (!ret.isNull) {
        results ~= ret.get;
      }
    }
    auto ret = this.flush();
    if (!ret.isNull) {
      results ~= ret.get;
    }
    return results;
  }

  private Nullable!ParseResult addLine(wstring line) {
    const Nullable!ParseResult hd = this.parseLine(line);

    if (hd.isNull) {
      return typeof(return).init;
    }
    ParseResult head = hd.get;

    Nullable!ParseResult result;

    if (head.head == this.currentHead) {
      this.lines ~= head.desc;
    } else {
      if (!this.currentHead.empty && this.lines.length > 0) {
        result = ParseResult(this.currentHead, this.lines.join("\n"));
      }
      this.currentHead = head.head;
      this.lines = [];
      this.lines ~= hd.desc;
    }

    return result;
  }

  private Nullable!ParseResult parseLine(wstring line) {
    if (line[0] != '■') {
      return typeof(return).init;
    }

    ParseResult result;

    const dindex1 = line.indexOf(DELIM1);
    if (dindex1 <= 0) {
      return typeof(return).init;
    }

    wstring firstHalf = line[1 .. dindex1];
    const dindex2 = firstHalf.indexOf(DELIM2);
    if (dindex2 >= 1) {
      result.head = line[1 .. dindex2 + 1];
      result.desc = line[dindex2 + 3 .. $];
    } else {
      result.head = firstHalf;
      result.desc = line[dindex1 + DELIM1.length .. $];
    }

    return nullable(result);
  }

  private Nullable!ParseResult flush() {
    ParseResult result;
    bool ret_is_not_null;

    if (this.currentHead && this.lines.length > 0) {
      result.head = currentHead;
      result.desc = this.lines.join("\n");
      ret_is_not_null = true;
    }

    this.currentHead = null;
    this.lines = [];

    if (ret_is_not_null) {
      return nullable(result);
    } else {
      return typeof(return).init;
    }
  }
}
