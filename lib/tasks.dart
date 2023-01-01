import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/services.dart' show rootBundle;
part 'tasks.g.dart';

enum TimerType {
  single, // a single timepoint
  daily, // daily timer
  weekDaily, // week day timer
  interval, // repeat after some interval
}

// {
//     "title":"Call Boss",
//     "desc":"",
//     "type":"single",
//     "timerTime":"2023-01-03 08:00:33",
//     "setTime":"2023-01-01 08:35:33",
//     "id":1,
//     "weekDay":[],
//     "interval":0,
//     "excludeWeekDay":[],
//     "excludeDailyTime":[],
//     "excludePeriod":[]
// },

@JsonSerializable(includeIfNull: false)
class TimerTask {
  String title = "Default";

  @JsonKey(includeIfNull: false)
  String desc = "Default";

  TimerType type = TimerType.single;

  @JsonKey(includeIfNull: false)
  String timerTime = "1970-01-01 08:00:33";

  String setTime = "1970-01-01 08:00:33";

  @JsonKey(includeIfNull: false)
  List<int> weekDay = [];

  @JsonKey(includeIfNull: false)
  int interval = 3600;

  int id = 0;

  @JsonKey(includeIfNull: false)
  List<int> excludeWeekDay = [];

  @JsonKey(includeIfNull: false)
  List<String> excludeDailyTime = [];

  @JsonKey(includeIfNull: false)
  List<String> excludePeriod = [];

  TimerTask(this.title, this.desc);
  @override
  String toString() {
    return jsonEncode(toJson());
  }

  factory TimerTask.fromJson(Map<String, dynamic> json) =>
      _$TimerTaskFromJson(json);
  Map<String, dynamic> toJson() => _$TimerTaskToJson(this);
}

typedef OnConfigReadyCallback = void Function();

@JsonSerializable(explicitToJson: true)
class Config {
  List<TimerTask> tasks = [];

  @JsonKey(ignore: true)
  static final Config _singleton = Config._internal();

  @JsonKey(ignore: true)
  bool ready = false;

  @JsonKey(ignore: true)
  final Map<String, OnConfigReadyCallback> _readyCallback =
      <String, OnConfigReadyCallback>{};

  Future<Config> loadJsonFile() async {
    Map<String, dynamic> map =
        jsonDecode(await rootBundle.loadString("assets/config.json"));
    Config config = Config.fromJson(map);
    // print("loading config from file: ${config.toString()}");
    return config;
  }

  factory Config() {
    return _singleton;
  }

  Config._internal() {
    print("Config created!");
    loadJsonFile().then((value) {
      ready = true;
      tasks = value.tasks;
      print("loading config from file over: ${toString()}");
      onReady();
    });
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);
  Map<String, dynamic> toJson() => _$ConfigToJson(this);

  void registerCallback(String key, OnConfigReadyCallback callback) {
    print("Config::registerCallback $key");
    _readyCallback[key] = callback;
    if (ready) {
      print("Config::registerCallback $key, already ready, call it now!");
      callback();
    }
  }

  void unregisterCallback(String key) {
    print("Config::unregisterCallback $key");
    _readyCallback.remove(key);
  }

  void onReady() {
    _readyCallback.forEach((key, value) {
      print("onReady, _readyCallback $key");
      value();
    });
  }
}
