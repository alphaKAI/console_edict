import std.stdio;
import std.string;
import std.conv;
import cedict.parser;
import std.datetime.stopwatch;
import cedict.config;

enum SETTING_FILE = "settings.json";

void main() {
  Config conf = new Config(File(SETTING_FILE, "r"));
  ParseResult[] results;
  StopWatch sw;

  writeln("reading and parsing file...");

  sw.start;
  if (!conf.dict.ready) {
    foreach (file_name, parser; conf.filename_and_parser_map) {
      results ~= parser.parseFile(File(file_name, "r"));
    }
  }
  sw.stop;

  writefln("Read and parse file is completed [%s]", sw.peek);
  sw.reset;

  writeln("building directory.... Internal Dictionary Driver : ", conf.dict);

  sw.start;
  if (!conf.dict.ready) {
    foreach (ParseResult result; results) {
      conf.dict.insert(result.head, result.desc);
    }
  }
  sw.stop;

  writefln("Prepare completed [%s]", sw.peek);
  sw.reset;

  for (;;) {
    write("WORD > ");
    wstring input = readln!wstring.chomp;

    if (input == ":q") {
      writeln("EXIT");
      break;
    }
    if (input == ":words") {
      writefln("%d words registered", results.length);
      continue;
    }

    auto mean = conf.dict.get(input);
    if (!mean.isNull) {
      writefln("<found the word> [%s]", input);
      writeln(mean.get);
    } else {
      writefln("<not found the word - %s>", input);
    }
  }
}
