import 'package:shared_preferences/shared_preferences.dart';

class InterviewProgressStore {
  InterviewProgressStore._();

  static final InterviewProgressStore instance = InterviewProgressStore._();

  static const _bookmarksKey = 'interview_bookmarked_question_ids';
  static const _completedKey = 'interview_completed_question_ids';
  static const _recentKey = 'interview_recent_question_ids';
  static const _recentLimit = 12;

  final Set<String> _bookmarkedQuestionIds = <String>{};
  final Set<String> _completedQuestionIds = <String>{};
  final List<String> _recentQuestionIds = <String>[];
  bool _isLoaded = false;

  Set<String> get bookmarkedQuestionIds =>
      Set<String>.unmodifiable(_bookmarkedQuestionIds);
  Set<String> get completedQuestionIds =>
      Set<String>.unmodifiable(_completedQuestionIds);
  List<String> get recentQuestionIds =>
      List<String>.unmodifiable(_recentQuestionIds);

  void resetInMemory() {
    _bookmarkedQuestionIds.clear();
    _completedQuestionIds.clear();
    _recentQuestionIds.clear();
    _isLoaded = false;
  }

  Future<void> load() async {
    if (_isLoaded) {
      return;
    }
    final preferences = await SharedPreferences.getInstance();
    _bookmarkedQuestionIds.addAll(
      preferences.getStringList(_bookmarksKey) ?? const <String>[],
    );
    _completedQuestionIds.addAll(
      preferences.getStringList(_completedKey) ?? const <String>[],
    );
    _recentQuestionIds.addAll(
      preferences.getStringList(_recentKey) ?? const <String>[],
    );
    _isLoaded = true;
  }

  Future<void> toggleBookmark(String questionId) async {
    await load();
    final next = Set<String>.of(_bookmarkedQuestionIds);
    if (!next.add(questionId)) {
      next.remove(questionId);
    }
    await _saveSet(_bookmarksKey, next);
    _bookmarkedQuestionIds
      ..clear()
      ..addAll(next);
  }

  Future<void> toggleCompleted(String questionId) async {
    await load();
    final next = Set<String>.of(_completedQuestionIds);
    if (!next.add(questionId)) {
      next.remove(questionId);
    }
    await _saveSet(_completedKey, next);
    _completedQuestionIds
      ..clear()
      ..addAll(next);
  }

  Future<void> recordViewed(String questionId) async {
    await load();
    final next = <String>[
      questionId,
      ..._recentQuestionIds.where((id) => id != questionId),
    ].take(_recentLimit).toList();
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.setStringList(_recentKey, next)) {
      throw Exception('Could not save recently viewed interview questions.');
    }
    _recentQuestionIds
      ..clear()
      ..addAll(next);
  }

  Future<void> _saveSet(String key, Set<String> values) async {
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.setStringList(key, values.toList()..sort())) {
      throw Exception('Could not save interview preparation progress.');
    }
  }
}
