import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_word_count_calendar/calendar_model.dart';
import 'package:novel_word_count_calendar/writing_event.dart';
import 'package:intl/intl.dart';

/// Defines a [Widget] that serves as a form for entering info about, and adding
/// a new [WritingEvent] to a [WritingProject].
///
/// Note that a user creates a new [WritingProject] when needed implicitely,
/// simply by adding a [WritingEvent] whose [projectName] is not being used by
/// any of the projects that already exist.
class WritingEventFormWidget extends StatefulWidget {
  final BuildContext context;
  final CalendarModel _model;
  final DateTime _date;

  const WritingEventFormWidget(this.context, this._model, this._date,
      {Key? key})
      : super(key: key);

  @override
  State<WritingEventFormWidget> createState() => _WritingEventFormWidgetState();
}

/// Defines [WritingEventFormWidget]'s [State].
class _WritingEventFormWidgetState extends State<WritingEventFormWidget> {
  final DateFormat _formatter = DateFormat.yMd();
  String _dropDownButtonValue = '';

  final TextEditingController projectNameController = TextEditingController();

  final TextEditingController wordCountController =
      TextEditingController(text: '');

  final TextEditingController noteController = TextEditingController(text: '');

  /// Adds a new [WritingEvent] to [widget._model].
  void _addEvent() {
    String projectName = projectNameController.text;
    String note = noteController.text;
    int? wordCount = int.tryParse(wordCountController.text);

    widget._model.addWritingEvent(
      WritingEvent(
        projectName,
        wordCount ?? 0,
        note,
        widget._date,
      ),
    );
  }

  /// Returns to the previous page, the one that pushed to this one.
  void _navigateToPreviousPage() {
    _addEvent();
    Navigator.pop(widget.context);
  }

  /// Gets the names of all existing [WritingProject]s and returns them as a
  /// [List] of [DropdownMenuItem]s.
  List<DropdownMenuItem<String>> _getExistingProjectNames() {
    List<DropdownMenuItem<String>> dropdownItems;
    if (widget._model.index.isEmpty) {
      dropdownItems = [
        const DropdownMenuItem<String>(
          value: '',
          child: Text(''),
        )
      ];
    } else {
      dropdownItems = widget._model.index.toList().map((e) {
        return DropdownMenuItem<String>(child: Text(e), value: e);
      }).toList();
    }

    return dropdownItems;
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> items = _getExistingProjectNames();
    return Scaffold(
      appBar: AppBar(
        title: Text(_formatter.format(widget._date)),
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: _navigateToPreviousPage,
        child: const Icon(Icons.add_task),
      ),
      body: Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: projectNameController,
                    decoration:
                        const InputDecoration(labelText: 'Project Name'),
                  ),
                ),
                DropdownButton<String>(
                  hint: const Text('Choose existing'),
                  underline: Container(
                    height: 1,
                    color: Colors.grey,
                  ),
                  icon: const Icon(Icons.arrow_drop_down),
                  iconSize: 76,
                  value: items[0].value,
                  items: items,
                  onChanged: (item) {
                    setState(() {
                      projectNameController.text = item ?? _dropDownButtonValue;
                      _dropDownButtonValue = item ?? _dropDownButtonValue;
                    });
                  },
                )
              ],
            ),
            TextFormField(
              controller: wordCountController,
              decoration: const InputDecoration(label: Text('Word Count')),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            TextFormField(
              controller: noteController,
              decoration: const InputDecoration(label: Text('Note')),
              keyboardType: TextInputType.multiline,
              maxLines: 8,
            ),
          ],
        ),
      ),
    );
  }
}
