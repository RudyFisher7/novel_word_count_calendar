import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Defines a [Widget] that displays the summary info for all the user's
/// [WritingProject]s, though it wouldn't know anything about them ;).
class SummaryWidget extends StatelessWidget {
  final Map<String, int> totalWordCounts;
  final Map<String, int> monthWordCounts;
  final Map<String, int> weekWordCounts;
  final DateTime dateTime;
  final DateFormat formatter = DateFormat.yMd();
  SummaryWidget(this.totalWordCounts, this.monthWordCounts, this.weekWordCounts,
      this.dateTime,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> keys = totalWordCounts.keys.toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
        centerTitle: true,
      ),
      body: ListView.separated(
        itemCount: keys.length,
        itemBuilder: (context, index) {
          String projectName = keys[index];
          return Column(
            children: [
              Text(projectName,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              ListTile(
                leading: Text('${totalWordCounts[projectName]}'),
                trailing: Text('${totalWordCounts[projectName]}'),
                title: const Text('Total'),
              ),
              ListTile(
                leading: Text('${monthWordCounts[projectName]}'),
                trailing: Text('${monthWordCounts[projectName]}'),
                title: Text('month of ${dateTime.month}-${dateTime.year}'),
              ),
              ListTile(
                leading: Text('${weekWordCounts[projectName]}'),
                trailing: Text('${weekWordCounts[projectName]}'),
                title: Text('week of ${formatter.format(dateTime)}'),
              ),
            ],
          );
        },
        separatorBuilder: (context, index) {
          return const Divider(
            thickness: 8.0,
          );
        },
      ),
    );
  }
}
