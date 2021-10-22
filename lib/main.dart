import 'package:flutter/material.dart';
import 'package:novel_word_count_calendar/calendar_model.dart';
import 'package:provider/provider.dart';

import 'home_widget.dart';

/// The entry point for this app.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

/// The top-most [Widget] of this app. Creates the app's [CalendarModel].
class MyApp extends StatelessWidget {
  final CalendarModel calendarModel = CalendarModel();
  MyApp({Key? key}) : super(key: key);

  /// Builds this [Widget].
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CalendarModel>(
      create: (context) => calendarModel,
      child: Consumer<CalendarModel>(
        builder: (context, model, child) => HomeWidget(calendarModel),
      ),
    );
  }
}
