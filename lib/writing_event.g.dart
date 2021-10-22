// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'writing_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WritingEvent _$WritingEventFromJson(Map<String, dynamic> json) => WritingEvent(
      json['projectName'] as String,
      json['wordCount'] as int,
      json['note'] as String,
      DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$WritingEventToJson(WritingEvent instance) =>
    <String, dynamic>{
      'projectName': instance.projectName,
      'wordCount': instance.wordCount,
      'note': instance.note,
      'date': instance.date.toIso8601String(),
    };
