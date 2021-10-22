import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novel_word_count_calendar/writing_event.dart';
import 'package:novel_word_count_calendar/writing_project.dart';
import 'package:novel_word_count_calendar/writing_project_json_serializable.dart';
import 'package:path_provider/path_provider.dart';

/// Defines the model for the app's calendar.
///
/// Uses JSON for local data storage.
class CalendarModel extends ChangeNotifier {
  static const String jsonExtension = '_dont_delete.json';

  /// An index of project names, also used for
  /// each project's fileName.
  Set<String> index = {};

  /// The projects in cache. Keys are the projects'
  /// names.
  final Map<String, WritingProject> _writingProjects = {};

  /// Creates [CalendarModel] objects with its [index] field populated
  /// and any corresponding [_writingProjects] loaded to memory.
  CalendarModel() {
    _readFromOrCreateIndexFile().then((value) {
      _loadProjects();
    });
  }

  /// Gets the total word counts of this [CalendarModel]'s projects as a
  /// [Map], where the keys are the project names as [String]s, and the
  /// values are the corresponding word counts as [int]s.
  Map<String, int> getTotalWordCounts() {
    Map<String, int> wordCounts = {};
    for (WritingProject project in _writingProjects.values) {
      wordCounts[project.name] = project.totalWordCount;
    }
    return wordCounts;
  }

  /// Gets the word counts of this [CalendarModel]'s projects during the
  /// calendar week of [dateTime] as a [Map], where the keys are the project
  /// names as [String]s, and the values are the corresponding word counts as
  /// [int]s.
  Map<String, int> getMonthWordCounts(DateTime dateTime) {
    Map<String, int> wordCounts = {};
    for (WritingProject project in _writingProjects.values) {
      wordCounts[project.name] = project.getMonthWordCount(dateTime);
    }
    return wordCounts;
  }

  /// Gets the word counts of this [CalendarModel]'s projects during the
  /// calendar month of [dateTime] as a [Map], where the keys are the project
  /// names as [String]s, and the values are the corresponding word counts as
  /// [int]s.
  Map<String, int> getWeekWordCounts(DateTime dateTime) {
    Map<String, int> wordCounts = {};
    for (WritingProject project in _writingProjects.values) {
      wordCounts[project.name] = project.getWeekWordCount(dateTime);
    }
    return wordCounts;
  }

  /// Gets the [WritingEvent]s that correspond to the given [dateTime].
  List<WritingEvent> getWritingEventsOnDate(DateTime dateTime) {
    List<WritingEvent> events = [];
    for (WritingProject project in _writingProjects.values) {
      events.addAll(
        project.getWritingEventsOnDate(dateTime),
      );
    }
    return events;
  }

  /// Adds the given [writingEvent] to the [WritingProject] whose name matches
  /// [writingEvent.projectName].
  ///
  /// If the [WritingProject] does not already exist, an empty one will be
  /// created.
  ///
  /// Notifies any listeners that are listening to this model.
  void addWritingEvent(WritingEvent writingEvent) async {
    WritingProject project;
    if (_writingProjects.containsKey(writingEvent.projectName)) {
      project = _writingProjects[writingEvent.projectName] ??
          WritingProject(writingEvent.projectName);
    } else {
      project =
          await _addWritingProject(WritingProject(writingEvent.projectName));
    }

    project.addWritingEvent(writingEvent);
    _writingProjects[project.name] = project;
    await _writeToProjectJsonFile(project);
    notifyListeners();
  }

  /// Removes the given [writingEvent] from the project it exists in, if it
  /// exists.
  ///
  /// Updates [writingEvent]'s project's corresponding JSON file, and
  /// [_localIndexFile].
  ///
  /// If the project becomes empty--i.e. it no longer has any events after
  /// [writingEvent]'s removal--removes the empty project from both [index] and
  /// [_writingProjects].
  ///
  /// Notifies any listeners that are listening to this model.
  ///
  /// See also [_addWritingProject].
  Future<bool> removeWritingEvent(WritingEvent writingEvent) async {
    bool foundEvent = false;
    Iterable iterable = _writingProjects.values;
    Iterator iterator = iterable.iterator;
    while (!foundEvent && iterator.moveNext()) {
      WritingProject project = iterator.current;
      if (project.contains(writingEvent)) {
        foundEvent = true;
        project.removeWritingEvent(writingEvent);
        if (!project.isEmpty()) {
          await _writeToProjectJsonFile(project);
        } else {
          await _removeWritingProject(project);
          await _deleteProjectJsonFile(project.name);
        }

        notifyListeners();
        return true;
      }
    }

    notifyListeners();
    return false;
  }

  /// Adds the [project] to both [index] and [_writingProjects].
  ///
  /// Updates [project]'s corresponding JSON file, and [_localIndexFile].
  ///
  /// Returns [project] after adding it.
  ///
  /// Notifies any listeners that are listening to this model.
  Future<WritingProject> _addWritingProject(WritingProject project) async {
    index.add(project.name);
    _writingProjects[project.name] = project;
    await _writeToProjectJsonFile(project);
    await _writeToIndexFile();
    notifyListeners();
    return project;
  }

  /// Removes [project] from both [index] and [_writingProjects].
  ///
  /// Notifies any listeners that are listening to this model.
  Future<bool> _removeWritingProject(WritingProject project) async {
    index.remove(project.name);
    _writingProjects.remove(project.name);
    await _writeToProjectJsonFile(project);
    await _writeToIndexFile();
    return true;
  }

  /************ Persistant Storage Handling Methods ***********/

  /// Gets the [_localFolderPath] for the app's user storage.
  Future<String> get _localFolderPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Gets this model's [_localIndexFile].
  Future<File> get _localIndexFile async {
    final path = await _localFolderPath;
    return File('$path/index$jsonExtension');
  }

  /// Reads from this model's [_localIndexFile].
  ///
  /// [_localIndexFile] is a JSON file that stores the data in [index].
  ///
  /// If one does not exist, it is created.
  Future<bool> _readFromOrCreateIndexFile() async {
    File file = await _localIndexFile;

    bool exists = await file.exists();

    if (exists) {
      String jsonString = await file.readAsString();
      List<dynamic> list = jsonDecode(jsonString);
      List<String> indexList = list.cast<String>();
      index = indexList.toSet();
    } else {
      await file.create();
    }

    return true;
  }

  /// Writes to this model's [_localIndexFile].
  Future<bool> _writeToIndexFile() async {
    File file = await _localIndexFile;
    List<String> indexList = index.toList();
    String jsonString = json.encode(indexList);
    await file.writeAsString(jsonString);
    return true;
  }

  /// Loads [_writingProjects].
  ///
  /// If one of the project's local JSON file was deleted (maybe by some
  /// meddling kids), it removes the project's name from [index] and updates
  /// [_localIndexFile].
  Future<bool> _loadProjects() async {
    String path = await _localFolderPath;
    File file;
    List<String> indexList = index.toList();

    for (int i = indexList.length - 1; i >= 0; i--) {
      String projectName = indexList[i];
      file = File('$path/$projectName$jsonExtension');
      bool exists = await file.exists();
      if (exists) {
        _writingProjects[projectName] = await _readProjectFromJsonFile(file);
      } else {
        index.remove(indexList[i]);
      }
    }

    await _writeToIndexFile();
    notifyListeners();
    return true;
  }

  /// Reads from the given [file], a JSON file containing an encoded
  /// [WritingProject], and returns the resulting [WritingProject].
  Future<WritingProject> _readProjectFromJsonFile(File file) async {
    try {
      String jsonString = await file.readAsString();
      Map<String, dynamic> project = jsonDecode(jsonString);
      WritingProjectJsonSerializable writingProjectJsonSerializable =
          WritingProjectJsonSerializable.fromJson(project);
      WritingProject waffles =
          writingProjectJsonSerializable.toWritingProject();
      return waffles;
    } catch (e) {
      print('------_readProjectFromJsonFile says-------: $e');
      return WritingProject('error'); //TODO: Handle exceptions better.
    }
  }

  /// Writes the given [project] to its local JSON file.
  ///
  /// If the file doesn't exist, one is created.
  Future<bool> _writeToProjectJsonFile(WritingProject project) async {
    try {
      String path = await _localFolderPath;
      File file = File('$path/${project.name}$jsonExtension');
      bool exists = await file.exists();
      if (!exists) {
        await file.create();
      }

      WritingProjectJsonSerializable writingProjectJsonSerializable =
          WritingProjectJsonSerializable(
        project.name,
        project.totalWordCount,
        project.projectMap,
      );

      Map<String, dynamic> projectMap = writingProjectJsonSerializable.toJson();
      String jsonString = jsonEncode(projectMap);
      await file.writeAsString(jsonString);
      return true;
    } catch (e) {
      print('------_writeToProjectJsonFile says-------: $e');
      return false;
      //TODO: Handle exceptions better.
    }
  }

  /// Deletes the file whose name corresponds to [projectName], effectively
  /// deleting any of the saved data in the project whose name is [projectName].
  Future<bool> _deleteProjectJsonFile(String projectName) async {
    String path = await _localFolderPath;
    File file = File('$path/$projectName$jsonExtension');
    bool exists = await file.exists();
    if (exists) {
      await file.delete();
      return true;
    }

    return false;
  }
}
