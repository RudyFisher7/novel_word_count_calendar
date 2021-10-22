import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'writing_event.g.dart';

/// Defines [WritingEvent]s.
///
/// Serializable to JSON.
@JsonSerializable()
class WritingEvent implements Comparable {
  String projectName;
  int wordCount;
  String note;
  DateTime date;

  WritingEvent(this.projectName, this.wordCount, this.note, this.date);

  factory WritingEvent.fromJson(Map<String, dynamic> json) =>
      _$WritingEventFromJson(json);

  Map<String, dynamic> toJson() => _$WritingEventToJson(this);

  /// Compares this to [other].
  ///
  /// If [other] is a [WritingEvent], simply compares their [date]s. Otherwise,
  /// returns 0.
  ///
  /// See also the API for [DateTime].
  @override
  int compareTo(Object? other) {
    WritingEvent otherWritingEvent;

    if (other is WritingEvent) {
      otherWritingEvent = other;

      return date.compareTo(otherWritingEvent.date);
    } else {
      return 0;
    }
  }

  /// Returns the [String] representation of this [WritingEvent].
  @override
  String toString() {
    return '${date.year}-${date.month}-${date.day}: $wordCount\n--$note';
  }

  /// Tests equality between this [WritingEvent] and [other].
  ///
  /// Returns true if [other] is a [WritingEvent], and all their fields are
  /// considered equal. Otherwise, returns false.
  @override
  bool operator ==(Object other) =>
      other is WritingEvent &&
      other.runtimeType == runtimeType &&
      other.projectName == projectName &&
      other.wordCount == wordCount &&
      other.note == note &&
      other.date.year == date.year &&
      other.date.month == date.month &&
      other.date.day == date.day;

  /// Defines the [hashCode] for this [WritingEvent].
  ///
  /// Uses [hashValues] on every field of this [WritingEvent].
  @override
  int get hashCode => hashValues(projectName, wordCount, note, date);
}
