import std.stdio;
import std.string;
import std.conv;
import cedict.parser;
import std.datetime.stopwatch;
import cedict.config;
import leveldb;

enum SETTING_FILE = "settings.json";

void main() {
  Config conf = new Config(File(SETTING_FILE, "r"));
  ParseResult[] results;
  StopWatch sw;

  if (!conf.dict.ready) {
    writeln("reading and parsing file...");

    sw.start;
    foreach (file_name, parser; conf.filename_and_parser_map) {
      results ~= parser.parseFile(File(file_name, "r"));
    }
    sw.stop;
    writefln("Read and parse file is completed [%s]", sw.peek);
    sw.reset;
  }

  if (!conf.dict.ready) {
    writeln("building dictionary.... Internal Dictionary Driver : ", conf.dict);
    sw.start;
    foreach (ParseResult result; results) {
      conf.dict.insert(result.head, result.desc);
    }
    sw.stop;

    writefln("Prepare completed [%s]", sw.peek);
    sw.reset;
  }

  //wstring[][wstring] did_you_mean_cache
  auto opt = new Options;
  opt.create_if_missing = true;
  enum DID_YOU_MEAN_DB_NAME = "DID_YOU_MEAN_CHACHE_DB";
  auto did_you_mean_db = new DB(opt, DID_YOU_MEAN_DB_NAME);

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
      writeln("did you mean?");

      auto res = did_you_mean_db.get_slice(input.to!string);

      enum SPECIAL_SEP = "__sep__";

      if (res.ok) {
        wstring[] did_you_means = res.as!(string).split(SPECIAL_SEP).to!(wstring[]);
        foreach (word; did_you_means) {
          writeln(word);
        }
      } else {
        import std.algorithm.comparison;
        import std.format;

        string[] did_you_mean_array;

        foreach (head; conf.dict.getHeads) {
          size_t lsd = levenshteinDistance(input, head);
          if (lsd <= 2) {
            wstring fmt = " - %s".format(head).to!wstring;
            writeln(fmt);
            did_you_mean_array ~= fmt.to!string;
          }
        }

        did_you_mean_db.put(input.to!string, did_you_mean_array.join(SPECIAL_SEP).to!string);
      }
    }
  }
}
