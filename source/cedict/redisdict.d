module cedict.redisdict;

import cedict.dictionary;
import cedict.parser;
import cedict.avl;
import std.format;
import std.typecons;
import tinyredis;

class RedisDictionary : Dictionary {
  private Redis redis;
  private bool _ready;

  this() {
    this.redis = new Redis;
    Response res = this.redis.send("get console_edict_initialized");
    this._ready = !res.isNil;
  }

  bool ready() {
    if (!this._ready) {
      Response res = this.redis.send("get console_edict_initialized");
      this._ready = !res.isNil;
    }

    return this._ready;
  }

  import std.stdio;

  void insert(wstring key, wstring value) {
    if (!this.ready) {
      this.redis.send("set console_edict_initialized true");
    }
    import std.array;

    string redis_cmd = `set "%s" "%s"`.format(key.replace("\"", "\\\""),
        value.replace("\"", "\\\""));

    try {
      this.redis.send(redis_cmd);
    } catch (RedisResponseException e) {
      writeln("<insert fail> redis_cmd : ", redis_cmd);
    }
  }

  Nullable!wstring get(wstring key) {
    string redis_cmd = "get %s".format(key);
    Response res;
    try {
      res = redis.send(redis_cmd);
    } catch (RedisResponseException e) {
      writeln("<getfailed> redis_cmd : ", redis_cmd);
    }

    if (res.isNil) {
      return typeof(return).init;
    } else {
      import std.conv;

      return nullable(res.value.to!wstring);
    }
  }

  bool exists(wstring key) {
    Response res = redis.send(" get \"%s\"".format(key));
    return !res.isNil;
  }

  private wstring[] heads_cache;
  wstring[] getHeads() {
    if (heads_cache.length) {
      return heads_cache;
    }
    Response res = redis.send("keys *");
    if (res.isArray) {
      import std.conv;

      foreach (v; res.values) {
        heads_cache ~= v.value.to!wstring;
      }
    }
    return heads_cache;
  }

}
