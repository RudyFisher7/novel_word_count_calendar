import 'package:flutter/material.dart';
import 'package:novel_word_count_calendar/writing_event.dart';

/// A [Widget] representing the display of a [WritingEvent] in a [ListTile].
class WritingEventListItemWidget extends StatelessWidget {
  final Function(WritingEvent) _onDeleteLongPressed;
  final WritingEvent _event;

  const WritingEventListItemWidget(this._event, this._onDeleteLongPressed,
      {Key? key})
      : super(key: key);

  /// Builds this [Widget] on rock 'n roll.
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ElevatedButton(
        onPressed: null,
        onLongPress: () {
          _onDeleteLongPressed(_event);
        },
        child: const Icon(Icons.delete_forever),
      ),
      title: Text('${_event.wordCount} -- ${_event.projectName}'),
      subtitle: Text(_event.note),
      trailing: ElevatedButton(
        onPressed: null,
        onLongPress: () {
          _onDeleteLongPressed(_event);
        },
        child: const Icon(Icons.delete_forever),
      ),
    );
  }
}
