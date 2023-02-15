// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasks.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimerTask _$TimerTaskFromJson(Map<String, dynamic> json) => TimerTask(
      json['title'] as String,
      json['desc'] as String,
    )
      ..type = $enumDecode(_$TimerTypeEnumMap, json['type'])
      ..state = $enumDecode(_$TaskStateEnumMap, json['state'])
      ..timerTime = json['timerTime'] as String
      ..setTime = json['setTime'] as String
      ..weekDay =
          (json['weekDay'] as List<dynamic>).map((e) => e as int).toList()
      ..interval = json['interval'] as int
      ..id = json['id'] as int
      ..excludeWeekDay = (json['excludeWeekDay'] as List<dynamic>)
          .map((e) => e as int)
          .toList()
      ..excludeDailyTime = (json['excludeDailyTime'] as List<dynamic>)
          .map((e) => e as String)
          .toList()
      ..excludePeriod = (json['excludePeriod'] as List<dynamic>)
          .map((e) => e as String)
          .toList();

Map<String, dynamic> _$TimerTaskToJson(TimerTask instance) => <String, dynamic>{
      'title': instance.title,
      'desc': instance.desc,
      'type': _$TimerTypeEnumMap[instance.type]!,
      'state': _$TaskStateEnumMap[instance.state]!,
      'timerTime': instance.timerTime,
      'setTime': instance.setTime,
      'weekDay': instance.weekDay,
      'interval': instance.interval,
      'id': instance.id,
      'excludeWeekDay': instance.excludeWeekDay,
      'excludeDailyTime': instance.excludeDailyTime,
      'excludePeriod': instance.excludePeriod,
    };

const _$TimerTypeEnumMap = {
  TimerType.single: 'single',
  TimerType.daily: 'daily',
  TimerType.weekDaily: 'weekDaily',
  TimerType.monthly: 'monthly',
  TimerType.yearly: 'yearly',
  TimerType.interval: 'interval',
};

const _$TaskStateEnumMap = {
  TaskState.normal: 'normal',
  TaskState.expired: 'expired',
  TaskState.disabled: 'disabled',
};

Config _$ConfigFromJson(Map<String, dynamic> json) => Config()
  ..tasks = (json['tasks'] as List<dynamic>)
      .map((e) => TimerTask.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$ConfigToJson(Config instance) => <String, dynamic>{
      'tasks': instance.tasks.map((e) => e.toJson()).toList(),
    };
