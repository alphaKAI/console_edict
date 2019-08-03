module cedict.config;

import cedict.dictionary;
import cedict.parser;
import cedict.eijiroparser;
import cedict.avldict;
import cedict.hashdict;
import std.stdio;
import std.format;
import std.string;
import std.json;

enum ConfigField {
  dict,
  maps
}

static enum string asStr(ConfigField cf) {
  final switch (cf) {
  case ConfigField.dict : return "dict";
  case ConfigField.maps : return "maps";
  }
}

enum DictKind {
  AVL,
  Hash
}

static enum string asStr(DictKind dk) {
  final switch (dk) {
  case DictKind.AVL : return "AVL";
  case DictKind.Hash : return "Hash";
  }
}

enum DriverKind {
  EIJIRO
}

static enum string asStr(DriverKind dk) {
  final switch (dk) {
  case DriverKind.EIJIRO : return "EIJIRO";
  }
}

class Config {
  DictParser[string] filename_and_parser_map;
  Dictionary dict;

  this(File fp) {
    string config_raw_data;
    foreach (line; fp.byLine) {
      config_raw_data ~= line;
    }

    auto parsed = parseJSON(config_raw_data);

    this.parse_config(parsed);
  }

  private void parse_config(JSONValue parsed) {
    // validate
    foreach (field; __traits(allMembers, ConfigField)) {
      if (field !in parsed.object) {
        throw new Exception("field of %s must be specified".format(field));
      }
    }

    string dict = parsed.object["dict"].str;
    final switch (dict) {
    case DictKind.AVL.asStr:
      this.dict = new AVLDictionary;
      break;
    case DictKind.Hash.asStr:
      this.dict = new HashDictionary;
      break;
    }

    import std.file;

    foreach (file_name, driver_jv; parsed.object["maps"].object) {
      if (!exists(file_name)) {
        throw new Exception("No such a dictionary file - %s".format(file_name));
      }

      string parser_driver = driver_jv.str;
      DictParser parser;
      final switch (parser_driver) {
      case DriverKind.EIJIRO.asStr:
        parser = new EijiroParser();
        break;
      }
      this.filename_and_parser_map[file_name] = parser;
    }
  }
}