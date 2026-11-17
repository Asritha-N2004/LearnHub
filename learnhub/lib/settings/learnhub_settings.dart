import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LearnHubSettings {
  final String learnerName;
  final String email;
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final bool learningRemindersEnabled;
  final bool assessmentNotificationsEnabled;
  final bool certificateNotificationsEnabled;
  final List<String> preferredSubjects;
  final int dailyLearningGoalMinutes;
  final String language;

  LearnHubSettings({
    this.learnerName = '',
    this.email = '',
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
    this.learningRemindersEnabled = true,
    this.assessmentNotificationsEnabled = true,
    this.certificateNotificationsEnabled = true,
    List<String> preferredSubjects = const <String>[],
    this.dailyLearningGoalMinutes = 30,
    this.language = 'English',
  }) : preferredSubjects = List<String>.unmodifiable(preferredSubjects);

  LearnHubSettings copyWith({
    String? learnerName,
    String? email,
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? learningRemindersEnabled,
    bool? assessmentNotificationsEnabled,
    bool? certificateNotificationsEnabled,
    List<String>? preferredSubjects,
    int? dailyLearningGoalMinutes,
    String? language,
  }) {
    return LearnHubSettings(
      learnerName: learnerName ?? this.learnerName,
      email: email ?? this.email,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      learningRemindersEnabled:
          learningRemindersEnabled ?? this.learningRemindersEnabled,
      assessmentNotificationsEnabled:
          assessmentNotificationsEnabled ??
          this.assessmentNotificationsEnabled,
      certificateNotificationsEnabled:
          certificateNotificationsEnabled ??
          this.certificateNotificationsEnabled,
      preferredSubjects: preferredSubjects ?? this.preferredSubjects,
      dailyLearningGoalMinutes:
          dailyLearningGoalMinutes ?? this.dailyLearningGoalMinutes,
      language: language ?? this.language,
    );
  }

  Map<String, Object?> toJson() => {
    'learnerName': learnerName,
    'email': email,
    'themeMode': themeMode.name,
    'notificationsEnabled': notificationsEnabled,
    'learningRemindersEnabled': learningRemindersEnabled,
    'assessmentNotificationsEnabled': assessmentNotificationsEnabled,
    'certificateNotificationsEnabled': certificateNotificationsEnabled,
    'preferredSubjects': preferredSubjects,
    'dailyLearningGoalMinutes': dailyLearningGoalMinutes,
    'language': language,
  };

  factory LearnHubSettings.fromJson(Map<String, dynamic> json) {
    final storedName = _stringOrDefault(json['learnerName'], '').trim();
    final themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == json['themeMode'],
      orElse: () => ThemeMode.system,
    );
    final subjects = json['preferredSubjects'];
    return LearnHubSettings(
      learnerName: storedName == 'Student' ? '' : storedName,
      email: _stringOrDefault(json['email'], ''),
      themeMode: themeMode,
      notificationsEnabled: json['notificationsEnabled'] is bool
          ? json['notificationsEnabled'] as bool
          : true,
      learningRemindersEnabled: json['learningRemindersEnabled'] is bool
          ? json['learningRemindersEnabled'] as bool
          : true,
      assessmentNotificationsEnabled:
          json['assessmentNotificationsEnabled'] is bool
          ? json['assessmentNotificationsEnabled'] as bool
          : true,
      certificateNotificationsEnabled:
          json['certificateNotificationsEnabled'] is bool
          ? json['certificateNotificationsEnabled'] as bool
          : true,
      preferredSubjects: subjects is List
          ? subjects.whereType<String>().toList()
          : const <String>[],
      dailyLearningGoalMinutes:
          json['dailyLearningGoalMinutes'] is int &&
              (json['dailyLearningGoalMinutes'] as int) > 0
          ? json['dailyLearningGoalMinutes'] as int
          : 30,
      language: _stringOrDefault(json['language'], 'English'),
    );
  }
}

String _stringOrDefault(Object? value, String fallback) {
  return value is String ? value : fallback;
}

class LearnHubSettingsStore {
  LearnHubSettingsStore._();

  static final LearnHubSettingsStore instance = LearnHubSettingsStore._();
  static const _storageKey = 'learnhub_settings_v1';

  final ValueNotifier<LearnHubSettings> settings =
      ValueNotifier<LearnHubSettings>(LearnHubSettings());
  bool _isLoaded = false;
  Future<void>? _loadFuture;

  Future<void> load() {
    if (_isLoaded) {
      return Future<void>.value();
    }
    return _loadFuture ??= _loadFromPreferences();
  }

  Future<void> _loadFromPreferences() async {
    try {
    final preferences = await SharedPreferences.getInstance();
    final json = preferences.getString(_storageKey);
    if (json != null) {
      final decoded = jsonDecode(json);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('LearnHub settings are not a JSON object.');
      }
      settings.value = LearnHubSettings.fromJson(decoded);
    }
    _isLoaded = true;
    } finally {
      _loadFuture = null;
    }
  }

  Future<void> save(LearnHubSettings value) async {
    await load();
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.setString(_storageKey, jsonEncode(value.toJson()))) {
      throw Exception('Could not save your LearnHub settings.');
    }
    settings.value = value;
  }

  Future<void> saveEmail(String email) async {
    await save(settings.value.copyWith(email: email));
  }

  void resetInMemory() {
    settings.value = LearnHubSettings();
    _isLoaded = false;
  }
}

class LocalPasswordStore {
  LocalPasswordStore._();

  static final LocalPasswordStore instance = LocalPasswordStore._();
  static const _passwordKey = 'learnhub_local_password';
  static const _accountPasswordPrefix = 'learnhub_local_password_';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String _keyForEmail(String? email) {
    final normalizedEmail = email?.trim().toLowerCase();
    if (normalizedEmail == null || normalizedEmail.isEmpty) {
      return _passwordKey;
    }
    return '$_accountPasswordPrefix${base64Url.encode(utf8.encode(normalizedEmail))}';
  }

  Future<bool> hasPassword({String? email}) async {
    return await _storage.read(key: _keyForEmail(email)) != null;
  }

  Future<bool> verifyPassword(String password, {String? email}) async {
    final storedPassword = await _storage.read(key: _keyForEmail(email));
    return email == null
        ? storedPassword == null || storedPassword == password
        : storedPassword != null && storedPassword == password;
  }

  Future<void> changePassword({
    String? email,
    required String? currentPassword,
    required String newPassword,
  }) async {
    if (newPassword.length < 8) {
      throw ArgumentError('Password must be at least 8 characters long.');
    }
    final key = _keyForEmail(email);
    final storedPassword = await _storage.read(key: key);
    if (storedPassword != null && storedPassword != currentPassword) {
      throw ArgumentError('The current password is incorrect.');
    }
    await _storage.write(key: key, value: newPassword);
  }

  Future<void> migrateLegacyPassword({
    required String email,
    required String fallbackPassword,
  }) async {
    final legacyPassword = await _storage.read(key: _passwordKey);
    await _storage.write(
      key: _keyForEmail(email),
      value: legacyPassword ?? fallbackPassword,
    );
    if (legacyPassword != null) {
      await _storage.delete(key: _passwordKey);
    }
  }

  Future<void> movePassword({
    required String fromEmail,
    required String toEmail,
  }) async {
    final oldKey = _keyForEmail(fromEmail);
    final newKey = _keyForEmail(toEmail);
    final password = await _storage.read(key: oldKey);
    if (password == null) {
      return;
    }
    await _storage.write(key: newKey, value: password);
    await _storage.delete(key: oldKey);
  }

  Future<void> deletePassword({String? email}) async {
    await _storage.delete(key: _keyForEmail(email));
  }

  Future<void> deleteAllPasswords() async {
    await _storage.deleteAll();
  }
}
