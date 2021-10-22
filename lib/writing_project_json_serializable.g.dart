// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'writing_project_json_serializable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WritingProjectJsonSerializable _$WritingProjectJsonSerializableFromJson(
        Map<String, dynamic> json) =>
    WritingProjectJsonSerializable(
      json['name'] as String,
      json['totalWordCount'] as int? ?? 0,
      (json['writingEventsByDateTime'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            DateTime.parse(k),
            (e as List<dynamic>)
                .map((e) => WritingEvent.fromJson(e as Map<String, dynamic>))
                .toList()),
      ),
    );

Map<String, dynamic> _$WritingProjectJsonSerializableToJson(
        WritingProjectJsonSerializable instance) =>
    <String, dynamic>{
      'name': instance.name,
      'totalWordCount': instance.totalWordCount,
      'writingEventsByDateTime': instance.writingEventsByDateTime
          .map((k, e) => MapEntry(k.toIso8601String(), e)),
    };
