import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:novel_word_count_calendar/writing_event.dart';
import 'package:novel_word_count_calendar/writing_project.dart';

part 'writing_project_json_serializable.g.dart';

/// Defines a [JsonSerializable] version of [WritingProject].
///
/// Basically, the same as [WritingProject]--data-wise--but uses a regular [Map]
/// to allow for JSON encoding.
@JsonSerializable()
class WritingProjectJsonSerializable {
  final String name;
  int totalWordCount = 0;
  Map<DateTime, List<WritingEvent>> writingEventsByDateTime;

  WritingProjectJsonSerializable(this.name,
      this.totalWordCount, this.writingEventsByDateTime);

  factory WritingProjectJsonSerializable.fromJson(Map<String, dynamic> json) =>
      _$WritingProjectJsonSerializableFromJson(json);

  Map<String, dynamic> toJson() => _$WritingProjectJsonSerializableToJson(this);

  /// Creates and returns a new [WritingProject] based on this
  /// [WritingProjectJsonSerializable]'s data.
  WritingProject toWritingProject() {
    LinkedHashMap<DateTime, List<WritingEvent>> hashBrowns = LinkedHashMap(
        equals: (a, b) =>
            a.year == b.year && a.month == b.month && a.day == b.day,
        hashCode: (a) => hashValues(a.year, a.month, a.day));
    hashBrowns.addAll(writingEventsByDateTime);
    WritingProject project =
        WritingProject.fromWritingProjectJsonSerializableInfo(
            name, totalWordCount, hashBrowns);
    return project;
  }
}
