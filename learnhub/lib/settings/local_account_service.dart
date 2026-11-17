import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../certificates/certificate_store.dart';
import '../interview/interview_progress.dart';
import 'course_progress_store.dart';
import 'learnhub_settings.dart';

class LearnHubUserAccount {
  final String fullName;
  final String email;

  const LearnHubUserAccount({required this.fullName, required this.email});
}

class LocalAccountService {
  LocalAccountService._();

  static const _accountsKey = 'learnhub_local_accounts_v1';
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static Future<LearnHubUserAccount> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final name = fullName.trim();
    final normalizedEmail = _normalizeEmail(email);
    if (name.isEmpty) {
      throw Exception('Enter your full name.');
    }
    if (!_emailPattern.hasMatch(normalizedEmail)) {
      throw Exception('Enter a valid email address.');
    }
    if (password.length < 8) {
      throw Exception('Password must be at least 8 characters long.');
    }

    final accounts = await _readAccounts();
    if (accounts.containsKey(normalizedEmail)) {
      throw Exception('An account already exists for this email.');
    }
    final account = LearnHubUserAccount(
      fullName: name,
      email: normalizedEmail,
    );
    await LocalPasswordStore.instance.changePassword(
      email: normalizedEmail,
      currentPassword: null,
      newPassword: password,
    );
    accounts[normalizedEmail] = account;
    try {
      await _writeAccounts(accounts);
    } on Exception {
      await LocalPasswordStore.instance.deletePassword(email: normalizedEmail);
      rethrow;
    }
    return account;
  }

  static Future<LearnHubUserAccount> authenticate({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    final accounts = await _readAccounts();
    var account = accounts[normalizedEmail];
    if (account == null) {
      await LearnHubSettingsStore.instance.load();
      final previousSettings = LearnHubSettingsStore.instance.settings.value;
      if (_normalizeEmail(previousSettings.email) != normalizedEmail) {
        throw Exception('No account found. Create an account to continue.');
      }
      if (!await LocalPasswordStore.instance.verifyPassword(password)) {
        throw Exception('The password is incorrect.');
      }
      account = LearnHubUserAccount(
        fullName: previousSettings.learnerName.trim(),
        email: normalizedEmail,
      );
      await LocalPasswordStore.instance.migrateLegacyPassword(
        email: normalizedEmail,
        fallbackPassword: password,
      );
      accounts[normalizedEmail] = account;
      await _writeAccounts(accounts);
      return account;
    }
    if (!await LocalPasswordStore.instance.verifyPassword(
      password,
      email: normalizedEmail,
    )) {
      throw Exception('The password is incorrect.');
    }
    return account;
  }

  static Future<void> updateProfile({
    required String currentEmail,
    required String fullName,
    required String newEmail,
  }) async {
    final oldKey = _normalizeEmail(currentEmail);
    final newKey = _normalizeEmail(newEmail);
    final accounts = await _readAccounts();
    final account = accounts.remove(oldKey);
    if (account == null) {
      return;
    }
    if (!_emailPattern.hasMatch(newKey)) {
      accounts[oldKey] = account;
      throw Exception('Enter a valid email address.');
    }
    if (newKey != oldKey && accounts.containsKey(newKey)) {
      accounts[oldKey] = account;
      throw Exception('An account already exists for this email.');
    }

    if (newKey != oldKey) {
      await LocalPasswordStore.instance.movePassword(
        fromEmail: oldKey,
        toEmail: newKey,
      );
    }
    accounts[newKey] = LearnHubUserAccount(
      fullName: fullName.trim(),
      email: newKey,
    );
    try {
      await _writeAccounts(accounts);
    } on Exception {
      accounts
        ..remove(newKey)
        ..[oldKey] = account;
      if (newKey != oldKey) {
        await LocalPasswordStore.instance.movePassword(
          fromEmail: newKey,
          toEmail: oldKey,
        );
      }
      rethrow;
    }
  }

  static Future<Map<String, LearnHubUserAccount>> _readAccounts() async {
    final preferences = await SharedPreferences.getInstance();
    final serialized = preferences.getString(_accountsKey);
    if (serialized == null) {
      return <String, LearnHubUserAccount>{};
    }
    final decoded = jsonDecode(serialized);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Saved local accounts are malformed.');
    }
    final accounts = <String, LearnHubUserAccount>{};
    for (final entry in decoded.entries) {
      final value = entry.value;
      if (value is! Map<String, dynamic> ||
          value['fullName'] is! String ||
          value['email'] is! String) {
        throw FormatException('Saved account "${entry.key}" is malformed.');
      }
      final email = _normalizeEmail(value['email'] as String);
      final fullName = (value['fullName'] as String).trim();
      if (email.isEmpty || fullName.isEmpty || email != entry.key) {
        throw FormatException('Saved account "${entry.key}" is invalid.');
      }
      accounts[email] = LearnHubUserAccount(
        fullName: fullName,
        email: email,
      );
    }
    return accounts;
  }

  static Future<void> _writeAccounts(
    Map<String, LearnHubUserAccount> accounts,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final serialized = jsonEncode({
      for (final entry in accounts.entries)
        entry.key: {
          'fullName': entry.value.fullName,
          'email': entry.value.email,
        },
    });
    if (!await preferences.setString(_accountsKey, serialized)) {
      throw Exception('Could not save your local account.');
    }
  }

  static String _normalizeEmail(String email) => email.trim().toLowerCase();
}

Future<void> deleteLocalLearnHubData() async {
  await LocalPasswordStore.instance.deleteAllPasswords();
  final preferences = await SharedPreferences.getInstance();
  if (!await preferences.clear()) {
    throw Exception('Could not delete saved LearnHub preferences.');
  }
  InterviewProgressStore.instance.resetInMemory();
  CourseProgressStore.instance.resetInMemory();
  CertificateStore.instance.resetInMemory();
  LearnHubSettingsStore.instance.resetInMemory();
}
