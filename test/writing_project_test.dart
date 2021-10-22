import 'package:novel_word_count_calendar/writing_event.dart';
import 'package:novel_word_count_calendar/writing_project.dart';
import 'package:novel_word_count_calendar/writing_project_json_serializable.dart';
import 'package:test/test.dart';

void main() {
  WritingProjectJsonSerializable cereal =
      WritingProjectJsonSerializable('empty map', 0, {});
  WritingProject waffles;

  setUp(() {});

  group('Test Constructions:', () {
    test('Construct Waffles', () {
      waffles = WritingProject('waffles');
      expect(waffles is WritingProject, true);
    });

    test('Convert Cereal to Waffles', () {
      waffles = cereal.toWritingProject();
      expect(waffles is WritingProject, true);
    });

    test('Waffles\'s LinkedHashMap has Events in It', () {
      DateTime date = DateTime(1994, 1, 10, 12, 45);
      DateTime date2 = DateTime(1994, 1, 10, 6, 15);
      DateTime date3 = DateTime(1994, 1, 10, 9);
      WritingEvent event = WritingEvent(
        'waffles',
        500,
        'hashbrowns are tasty',
        date,
      );

      WritingEvent eventClone = WritingEvent(
        'waffles',
        500,
        'hashbrowns are tasty',
        date3,
      );

      WritingEvent event2 = WritingEvent(
        'waffles',
        500,
        'sausage links are tasty',
        date2,
      );

      WritingEvent event2Clone = WritingEvent(
        'waffles',
        500,
        'sausage links are tasty',
        date2,
      );
      cereal.writingEventsByDateTime[event.date] = [event, eventClone];
      cereal.writingEventsByDateTime[event2.date] = [event2, event2Clone];
      waffles = cereal.toWritingProject();
      expect(
        !waffles.isEmpty(),
        true,
      );
    });
  });

  group('Adding and Removing Writing Events:', () {
    test('Add Writing Event with Specific Time', () {
      waffles = WritingProject('waffles');
      DateTime date = DateTime(1994, 1, 10, 12, 45);

      waffles.addWritingEvent(
        WritingEvent(
          'waffles',
          500,
          'hashbrowns are tasty',
          date,
        ),
      );
      expect(
        waffles.getWritingEventsOnDate(date).isNotEmpty,
        true,
      );
    });

    test('Remove Only Writing Event from List with Specific Time', () {
      waffles = WritingProject('waffles');
      DateTime date = DateTime(1994, 1, 10, 12, 45);
      DateTime date2 = DateTime(1994, 1, 10, 6, 15);
      WritingEvent event2 = WritingEvent(
        'waffles',
        500,
        'hashbrowns are tasty',
        date2,
      );

      waffles.addWritingEvent(
        WritingEvent(
          'waffles',
          500,
          'hashbrowns are tasty',
          date,
        ),
      );

      waffles.removeWritingEvent(event2);
      expect(waffles.getWritingEventsOnDate(date), []);
    });

    test('Remove One of Several Writing Event from List with Specific Time',
        () {
      waffles = WritingProject('waffles');
      DateTime date = DateTime(1994, 1, 10, 12, 45);
      DateTime date2 = DateTime(1994, 1, 10, 6, 15);
      DateTime date3 = DateTime(1994, 1, 10, 9);
      WritingEvent event = WritingEvent(
        'waffles',
        500,
        'hashbrowns are tasty',
        date,
      );

      WritingEvent eventClone = WritingEvent(
        'waffles',
        500,
        'hashbrowns are tasty',
        date3,
      );

      WritingEvent event2 = WritingEvent(
        'waffles',
        500,
        'sausage links are tasty',
        date2,
      );

      WritingEvent event2Clone = WritingEvent(
        'waffles',
        500,
        'sausage links are tasty',
        date2,
      );

      waffles.addWritingEvent(event);
      waffles.addWritingEvent(event2Clone);

      waffles.removeWritingEvent(event2);
      expect(waffles.getWritingEventsOnDate(date), [eventClone]);
    });
  });

  group('Test Retrieving Writing Events from Map:', () {
    test('Retrieve a Writing Event on Date', () {
      waffles = WritingProject('waffles');
      DateTime date = DateTime(1994, 1, 10);
      WritingEvent comparisonEvent = WritingEvent(
        'waffles',
        500,
        'hashbrowns are tasty',
        date,
      );

      waffles.addWritingEvent(
        WritingEvent(
          'waffles',
          500,
          'hashbrowns are tasty',
          DateTime(1994, 1, 10),
        ),
      );
      expect(waffles.getWritingEventsOnDate(date), [comparisonEvent]);
    });

    test('Retrieve a Writing Event on Date with Different Time Components', () {
      waffles = WritingProject('waffles');
      DateTime date = DateTime(1994, 1, 10, 23, 30);

      waffles.addWritingEvent(
        WritingEvent(
          'waffles',
          500,
          'hashbrowns are tasty',
          DateTime(1994, 1, 10),
        ),
      );
      expect(waffles.getWritingEventsOnDate(date).isNotEmpty, true);
    });
  });
}
