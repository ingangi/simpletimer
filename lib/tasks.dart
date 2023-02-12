import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'notify.dart';
import 'dart:collection';
import 'package:intl/intl.dart';
part 'tasks.g.dart';

enum TimerType {
  single, // a single timepoint
  daily, // daily timer
  weekDaily, // week day timer
  monthly, // month day timer
  yearly, // year day timer
  interval, // repeat after some interval
}

int monthDayCount(int year, int month) {
  if (month < 1 || month > 12) {
    return 0;
  }
  return DateTime(year, month + 1, 0).day;
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

  bool poll(DateTime now) {
    if (_nextTime == null) {
      _updateNextTime(now);
    }
    if (_nextTime == null) {
      return false;
    }
    if (now.isAfter(_nextTime!)) {
      _nextTime = null;
      print("[$now] TIMEOUT! ${toString()}");
      Notifier().ShowNotification(title, "It's time for $title");
      return true;
    }
    return false;
  }

  DateTime? _checkExclude(DateTime now) {
    // print(
    //     "_checkExclude start($id), $excludePeriod, $excludeDailyTime, $excludeWeekDay");
    if (excludePeriod.length == 2) {
      DateTime startTime = DateTime.parse(excludePeriod[0]);
      DateTime endTime = DateTime.parse(excludePeriod[1]);
      if (endTime.isAfter(startTime) &&
          now.isAfter(startTime) &&
          now.isBefore(endTime)) {
        now = endTime.add(const Duration(seconds: 1));
        print(
            "_checkExclude, now updated to $now for excludePeriod($excludePeriod)");
      }
    }

    if (excludeDailyTime.length == 2) {
      DateTime startTime = DateFormat.Hm().parse(excludeDailyTime[0]);
      startTime = DateTime(now.year, now.month, now.day, startTime.hour,
          startTime.minute, startTime.second);
      DateTime endTime = DateFormat.Hm().parse(excludeDailyTime[1]);
      endTime = DateTime(now.year, now.month, now.day, endTime.hour,
          endTime.minute, endTime.second);
      if (endTime.isBefore(startTime)) {
        endTime = endTime.add(const Duration(days: 1));
      }
      if (startTime.difference(endTime) < const Duration(days: 1)) {
        if (now.isAfter(startTime) && now.isBefore(endTime)) {
          now = endTime.add(const Duration(seconds: 1));
          print(
              "_checkExclude, now updated to $now for excludeDailyTime($excludeDailyTime)");
        }
      } else {
        print(
            "_checkExclude, all time exclued by excludeDailyTime($excludeDailyTime)!!!");
        return null;
      }
    }

    if (excludeWeekDay.isNotEmpty) {
      if (excludeWeekDay.length > 6) {
        var uniqueIntList = LinkedHashSet<int>.from(excludeWeekDay);
        uniqueIntList.removeWhere((element) => element > 7 || element < 1);
        excludeWeekDay = uniqueIntList.toList();
        if (excludeWeekDay.length > 6) {
          print(
              "_checkExclude, all time exclued by excludeWeekDay($excludeWeekDay)!!!");
          return null;
        }
      }
      if (excludeWeekDay.contains(now.weekday)) {
        now = now.add(const Duration(days: 1));
        while (excludeWeekDay.contains(now.weekday)) {
          now = now.add(const Duration(days: 1));
        }
        now = DateTime(now.year, now.month, now.day);
        print(
            "_checkExclude, now updated to $now for excludeWeekDay($excludeWeekDay)");
      }
      while (excludeWeekDay.contains(now.weekday)) {
        now = now.add(const Duration(days: 1));
        print(
            "_checkExclude, now updated to $now for excludeWeekDay($excludeWeekDay)");
      }
    }

    return now;
  }

  void _updateNextTime(DateTime now) {
    _nextTime = null;
    switch (type) {
      case TimerType.single:
        _nextTime = DateTime.parse(timerTime);
        if (now.isAfter(_nextTime!)) {
          _nextTime = null;
        }
        break;
      case TimerType.daily:
        _nextTime = DateTime.parse(timerTime);
        _nextTime = DateTime(now.year, now.month, now.day, _nextTime!.hour,
            _nextTime!.minute, _nextTime!.second);
        if (_nextTime!.isBefore(now)) {
          _nextTime = _nextTime!.add(const Duration(days: 1));
        }
        break;
      case TimerType.weekDaily:
        for (int i = 0; i < 8; ++i) {
          DateTime tmp = now.add(Duration(days: i));
          if (weekDay.contains(tmp.weekday)) {
            _nextTime = DateTime.parse(timerTime);
            _nextTime = DateTime(tmp.year, tmp.month, tmp.day, _nextTime!.hour,
                _nextTime!.minute, _nextTime!.second);
            if (now.isAfter(_nextTime!)) {
              _nextTime = null;
              continue;
            }
            break;
          }
        }
        break;
      case TimerType.monthly:
        _nextTime = DateTime.parse(timerTime);
        int addNextMonth = 0;
        if (now.day >= _nextTime!.day) {
          _nextTime = DateTime(now.year, now.month, _nextTime!.day,
              _nextTime!.hour, _nextTime!.minute, _nextTime!.second);
          if (_nextTime!.isBefore(now)) {
            addNextMonth = 1;
          }
        }
        DateTime tmp = now;
        int addMonth = 0;
        if (_nextTime!.day >
            monthDayCount(now.year, now.month + addNextMonth)) {
          while (true) {
            ++addMonth;
            tmp = DateTime(
                now.year, now.month + addNextMonth + addMonth, _nextTime!.day);
            if (_nextTime!.day <= monthDayCount(tmp.year, tmp.month)) {
              break;
            }
          }
        }
        _nextTime = DateTime(
            now.year,
            now.month + addNextMonth + addMonth,
            _nextTime!.day,
            _nextTime!.hour,
            _nextTime!.minute,
            _nextTime!.second);
        break;
      case TimerType.yearly:
        _nextTime = DateTime.parse(timerTime);
        int setDay = _nextTime!.day;
        int setMonth = _nextTime!.month;
        int addNextYear = 0;
        int addYear = 0;
        _nextTime = DateTime(now.year, _nextTime!.month, _nextTime!.day,
            _nextTime!.hour, _nextTime!.minute, _nextTime!.second);
        if (_nextTime!.isBefore(now)) {
          addNextYear = 1;
        }
        DateTime tmp = DateTime(now.year + addNextYear, setMonth, setDay,
            _nextTime!.hour, _nextTime!.minute, _nextTime!.second);
        if (setDay != tmp.day || setMonth != tmp.month) {
          while (true) {
            ++addYear;
            tmp = DateTime(now.year + addNextYear + addYear, setMonth, setDay);
            if (setDay == tmp.day && setMonth == tmp.month) {
              break;
            }
          }
        }
        _nextTime = DateTime(now.year + addNextYear + addYear, setMonth, setDay,
            _nextTime!.hour, _nextTime!.minute, _nextTime!.second);
        break;
      case TimerType.interval:
        if (interval <= 0 || setTime.isEmpty) {
          break;
        }
        int nowStamp = now.millisecondsSinceEpoch ~/ 1000;
        DateTime start = DateTime.parse(setTime);
        int startStamp = start.millisecondsSinceEpoch ~/ 1000;
        int distance = nowStamp - startStamp;
        int left = interval - (distance % interval);
        _nextTime = now.add(Duration(seconds: left));
        break;
    }
    if (_nextTime == null) {
      print("_updateNextTime failed, type=$type");
    } else {
      var excluded = _checkExclude(_nextTime!);
      if (excluded == null) {
        _nextTime = null;
        print("_updateNextTime failed on _checkExclude, type=$type");
      } else if (excluded.isAfter(_nextTime!)) {
        // reproduce
        print(
            "_updateNextTime try to reproduce, type=$type, excluded=$excluded");
        _updateNextTime(excluded);
      } else {
        print("_updateNextTime over, type=$type, _nextTime=$_nextTime");
      }
    }
  }

  @JsonKey(ignore: true)
  DateTime? _nextTime;
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
    Notifier();
    startTimer();
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

  void pollTasks() {
    DateTime now = DateTime.now();
    print("pollTasks: ${now}");
    for (var element in tasks) {
      element.poll(now);
    }
  }

  void startTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (ready) {
        pollTasks();
      }
    });
  }
}
