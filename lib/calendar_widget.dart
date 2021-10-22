import 'package:flutter/material.dart';
import 'package:novel_word_count_calendar/calendar_model.dart';
import 'package:novel_word_count_calendar/writing_event.dart';
import 'package:novel_word_count_calendar/writing_event_list_item_widget.dart';
import 'package:novel_word_count_calendar/summary_widget.dart';
import 'package:novel_word_count_calendar/writing_event_form_widget.dart';
import 'package:table_calendar/table_calendar.dart';

/// Defines a [CalendarWidget].
///
/// This is the main screen the user sees and interacts with, and the first one
/// that displays when the app is loaded.
class CalendarWidget extends StatefulWidget {
  final CalendarModel calendarModel;
  final ButtonStyle _buttonStyle =
      ElevatedButton.styleFrom(minimumSize: const Size(120.0, 32.0));

  CalendarWidget(this.calendarModel, {Key? key}) : super(key: key);

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

/// [CalendarWidget]'s [State] definition.
class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<WritingEvent> _selectedDayWritingEvents = [];

  /// Returns the [TableCalendar] to the present day.
  void _returnToCurrentMonth() {
    setState(() {
      _selectedDay = DateTime.now();
      _focusedDay = DateTime.now();
    });
  }

  /// Changes the [TableCalendar]'s [format].
  ///
  /// See [TableCalendar]'s API on pub.dev for more info. Basically changes the
  /// view between full month, 2-week, and 1-week views.
  void _onFormatChanged(CalendarFormat format) {
    setState(() {
      _calendarFormat = format;
    });
  }

  /// Updates [_selectedDay] and [_focusedDay] to the
  /// [selectedDay], which the user selected.
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    _selectedDayWritingEvents =
        widget.calendarModel.getWritingEventsOnDate(selectedDay);
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  /// Navigates to the app's summary page [SummaryWidget].
  ///
  /// See alse [SummaryWidget].
  void _navigateToSummaryPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SummaryWidget(
          widget.calendarModel.getTotalWordCounts(),
          widget.calendarModel.getMonthWordCounts(_selectedDay),
          widget.calendarModel.getWeekWordCounts(_selectedDay),
          _selectedDay,
        ),
      ),
    );
  }

  /// Navigates to the app's page for adding [WritingEvent]s.
  ///
  /// See also [WritingEventFormWidget].
  void _navigateToAddWritingEventPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WritingEventFormWidget(
          context,
          widget.calendarModel,
          _selectedDay,
        ),
      ),
    );
  }

  /// Gets the [WritingEvent]s for the given [day] and returns them.
  ///
  /// See also [CalendarModel].
  List<WritingEvent> _getEventsForDay(DateTime day) {
    List<WritingEvent> writingEvents =
        widget.calendarModel.getWritingEventsOnDate(day);

    return writingEvents;
  }

  /// Deletes the given [writingEvent].
  ///
  /// See also [CalendarModel].
  void _onDeleteLongPressed(WritingEvent writingEvent) {
    widget.calendarModel.removeWritingEvent(writingEvent);
    _selectedDayWritingEvents =
        widget.calendarModel.getWritingEventsOnDate(_selectedDay);
  }

  /// Builds this [Widget].
  @override
  Widget build(BuildContext context) {
    _selectedDayWritingEvents =
        widget.calendarModel.getWritingEventsOnDate(_selectedDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TableCalendar(
          eventLoader: _getEventsForDay,
          calendarFormat: _calendarFormat,
          onFormatChanged: _onFormatChanged,
          firstDay: DateTime(1994, DateTime.january, 1),
          focusedDay: _focusedDay,
          lastDay: DateTime(DateTime.now().year + 1, DateTime.december, 0),
          selectedDayPredicate: (selectedDateTime) {
            return isSameDay(_selectedDay, selectedDateTime);
          },
          onDaySelected: _onDaySelected,
          onPageChanged: (focusedDateTime) {
            _focusedDay = focusedDateTime;
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              style: widget._buttonStyle,
              onPressed: _returnToCurrentMonth,
              child: const Icon(Icons.today),
            ),
            ElevatedButton(
              style: widget._buttonStyle,
              onPressed: _navigateToSummaryPage,
              child: const Icon(Icons.summarize),
            ),
            ElevatedButton(
              style: widget._buttonStyle,
              onPressed: _navigateToAddWritingEventPage,
              child: const Icon(Icons.add),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _selectedDayWritingEvents.length,
            itemBuilder: (context, index) {
              return WritingEventListItemWidget(
                  _selectedDayWritingEvents[index], _onDeleteLongPressed);
            },
          ),
        ),
      ],
    );
  }
}
