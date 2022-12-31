import 'dart:io';

class TimerTask {
  String title = "Wakeup";
  String desc = "Every Day at 08:00AM";

  TimerTask(this.title, this.desc);
}

class Config {
  List<TimerTask> tasks = [];
  static final Config _singleton = Config._internal();
  factory Config() {
    return _singleton;
  }
  Config._internal() {
    print("Config created!");

    // fake tasks
    tasks.add(TimerTask("Getup", "Every Day at 09:00AM"));
    tasks.add(TimerTask("English Class", "Every Monday at 10:00AM"));
    tasks.add(TimerTask("McDonal", "Every Friday at 7:00PM"));
  }
  // @override
  // String toString() {
  //   return jsonEncode(toJson());
  // }
  // factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);
  // Map<String, dynamic> toJson() => _$ConfigToJson(this);
}
