import 'package:shared_preferences/shared_preferences.dart';

class CourseProgressStore {
  CourseProgressStore._();

  static final CourseProgressStore instance = CourseProgressStore._();
  static const _storageKey = 'learnhub_completed_lesson_ids';

  final Set<String> _completedLessonIds = <String>{};
  bool _isLoaded = false;

  Set<String> get completedLessonIds =>
      Set<String>.unmodifiable(_completedLessonIds);

  Future<Set<String>> load() async {
    if (!_isLoaded) {
      final preferences = await SharedPreferences.getInstance();
      _completedLessonIds.addAll(
        preferences.getStringList(_storageKey) ?? const <String>[],
      );
      _isLoaded = true;
    }
    return completedLessonIds;
  }

  Future<bool> markCompleted(String lessonId) async {
    await load();
    if (_completedLessonIds.contains(lessonId)) {
      return false;
    }
    final next = <String>{..._completedLessonIds, lessonId};
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.setStringList(_storageKey, next.toList()..sort())) {
      throw Exception('Could not save course progress.');
    }
    _completedLessonIds
      ..clear()
      ..addAll(next);
    return true;
  }

  void resetInMemory() {
    _completedLessonIds.clear();
    _isLoaded = false;
  }
}
