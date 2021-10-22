import 'package:flutter/material.dart';
import 'calendar_model.dart';
import 'calendar_widget.dart';

/// This app's home screen.
///
/// It builds a [Scaffold] whose body is a [CalendarWidget].
class HomeWidget extends StatelessWidget {
  final CalendarModel calendarModel;
  const HomeWidget(this.calendarModel, {Key? key}) : super(key: key);

  /// Builds this [Widget].
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Writing Progress Calendar Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Progress Calendar'),
        ),
        body: Center(
          child: CalendarWidget(calendarModel),
        ),
      ),
    );
  }
}
