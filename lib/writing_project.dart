import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:novel_word_count_calendar/writing_event.dart';

/// Defines [WritingProject]s.
class WritingProject {
  final String name;
  int _totalWordCount = 0;
  LinkedHashMap<DateTime, List<WritingEvent>> _writingEventsByDateTime =
      LinkedHashMap(
          equals: (a, b) =>
              a.year == b.year && a.month == b.month && a.day == b.day,
          hashCode: (a) => hashValues(a.year, a.month, a.day));

  /// Creates a [WritingProject].
  WritingProject(this.name, [this._totalWordCount = 0]);

  ///
  WritingProject.fromWritingProjectJsonSerializableInfo(
    this.name,
    this._totalWordCount,
    this._writingEventsByDateTime,
  );

  /// Adds the given [writingEvent] to [_writingEventsByDateTime].
  ///
  /// Ensures this project's [_totalWordCount] remains accurate after removing.
  void addWritingEvent(WritingEvent writingEvent) {
    if (_writingEventsByDateTime[writingEvent.date] == null) {
      _writingEventsByDateTime[writingEvent.date] = [];
    }
    _writingEventsByDateTime[writingEvent.date]?.add(writingEvent);
    _totalWordCount += writingEvent.wordCount;
  }

  /// Removes the given [writingEvent] from [_writingEventsByDateTime].
  ///
  /// Ensures this project's [_totalWordCount] remains accurate after adding.
  void removeWritingEvent(WritingEvent writingEvent) {
    List<WritingEvent> events =
        _writingEventsByDateTime[writingEvent.date] ?? [];
    if (events.remove(writingEvent)) {
      _totalWordCount -= writingEvent.wordCount;

      // If the list of events is now empty, then remove
      // the key: value pair completely from the map.
      // Otherwise, update the map.
      if (events.isEmpty) {
        _writingEventsByDateTime.remove(writingEvent.date);
      } else {
        _writingEventsByDateTime[writingEvent.date] = events;
      }
    }
  }

  /// Gets the [WritingEvents] on the given [day] as a [List].
  List<WritingEvent> getWritingEventsOnDate(DateTime day) {
    return _writingEventsByDateTime[day] ?? [];
  }

  /// Gets the word count for the week of the given [day].
  ///
  /// Sunday is considered the first day of the week.
  int getWeekWordCount(DateTime day) {
    DateTime sunday = day;
    while (sunday.weekday != DateTime.sunday) {
      sunday = sunday.subtract(const Duration(days: 1));
    }
    DateTime firstDay = sunday.subtract(const Duration(days: 1));
    DateTime lastDay = sunday.add(const Duration(days: 7));

    return _getWordCountHelper(
      firstDay,
      lastDay,
    );
  }

  /// Gets the word count for the entire month the given [day] is in.
  int getMonthWordCount(DateTime day) {
    DateTime firstDay = DateTime(day.year, day.month, 0);
    DateTime lastDay = DateTime(day.year, day.month + 1);

    return _getWordCountHelper(firstDay, lastDay);
  }

  /// Helper function that gets the word count between [firstDay] and [lastDay],
  /// exclusive.
  int _getWordCountHelper(DateTime firstDay, DateTime lastDay) {
    int sum = 0;

    for (DateTime date in _writingEventsByDateTime.keys) {
      int comparedToFirstDay = _compareDates(firstDay, date);
      int comparedToLastDay = _compareDates(date, lastDay);

      if (comparedToFirstDay < 0 && comparedToLastDay < 0) {
        List<WritingEvent> events = _writingEventsByDateTime[date] ?? [];
        for (WritingEvent event in events) {
          sum += event.wordCount;
        }
      }
    }

    return sum;
  }

  /// Compares [date1] with [date2]. If [date1] comes before [date2], returns
  /// a negative number, if after, returns a positive number, otherwise returns
  /// 0.
  int _compareDates(DateTime date1, DateTime date2) {
    int result = 0;

    // If the years are different, then one date obviously must come before the
    // other
    if (date1.year < date2.year) {
      return -1;
    } else if (date1.year > date2.year) {
      return 1;
    }

    // If the months are different, then one date obviously must come before the
    // other
    if (date1.month < date2.month) {
      return -1;
    } else if (date1.month > date2.month) {
      return 1;
    }

    // If the days are different, then one date obviously must come before the
    // other
    if (date1.day < date2.day) {
      return -1;
    } else if (date1.day > date2.day) {
      return 1;
    }

    return result;
  }

  /// Gets [totalWordCount] accross all [WritingEvent]s in this
  /// [WritingProject].
  int get totalWordCount => _totalWordCount;

  /// Gets this [WritingProject]'s underlying [WritingEvent] data as a [Map]
  /// whose keys are [DateTime] objects, and values are [List]s of
  /// [WritingEvent]s.
  Map<DateTime, List<WritingEvent>> get projectMap =>
      Map.from(_writingEventsByDateTime);

  /// Checks if this [WritingProject] has any [WritingEvent]s. If not, it is
  /// considered empty.
  bool isEmpty() {
    bool isPresumablyEmpty = true;
    Iterable<List<WritingEvent>> lists = _writingEventsByDateTime.values;
    Iterator<List<WritingEvent>> iterator = lists.iterator;

    while (isPresumablyEmpty && iterator.moveNext()) {
      if (iterator.current.isNotEmpty) {
        isPresumablyEmpty = false;
      }
    }

    return isPresumablyEmpty;
  }

  /// Checks if the given [writingEvent] is found in the data encapsulated by
  /// this [WritingProject].
  bool contains(WritingEvent writingEvent) {
    bool contains = false;
    Iterable<List<WritingEvent>> lists = _writingEventsByDateTime.values;
    Iterator<List<WritingEvent>> iterator = lists.iterator;

    while (!contains && iterator.moveNext()) {
      if (iterator.current.isNotEmpty) {
        contains = iterator.current.contains(writingEvent);
      }
    }

    return contains;
  }

  /// Returns the [String] representation of this [WritingProject].
  @override
  String toString() {
    return '''
    |==${super.toString()}: $name-----------------------|
    | Words: $_totalWordCount                           |_______________________
    |$_writingEventsByDateTime
    ''';
  }
}
