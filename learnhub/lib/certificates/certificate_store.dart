import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum CertificateKind { course, assessment }

class LearnHubCertificate {
  final String id;
  final String title;
  final String courseName;
  final String learnerName;
  final DateTime completedAt;
  final CertificateKind kind;
  final String sourceKey;

  const LearnHubCertificate({
    required this.id,
    required this.title,
    required this.courseName,
    required this.learnerName,
    required this.completedAt,
    required this.kind,
    required this.sourceKey,
  });

  LearnHubCertificate copyWith({String? learnerName}) {
    return LearnHubCertificate(
      id: id,
      title: title,
      courseName: courseName,
      learnerName: learnerName ?? this.learnerName,
      completedAt: completedAt,
      kind: kind,
      sourceKey: sourceKey,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'courseName': courseName,
    'learnerName': learnerName,
    'completedAt': completedAt.toIso8601String(),
    'kind': kind.name,
    'sourceKey': sourceKey,
  };

  factory LearnHubCertificate.fromJson(Map<String, dynamic> json) {
    final kind = CertificateKind.values.firstWhere(
      (value) => value.name == json['kind'],
      orElse: () => CertificateKind.course,
    );
    return LearnHubCertificate(
      id: _requiredString(json, 'id'),
      title: _requiredString(json, 'title'),
      courseName: _requiredString(json, 'courseName'),
      learnerName: _requiredString(json, 'learnerName'),
      completedAt: DateTime.parse(_requiredString(json, 'completedAt')),
      kind: kind,
      sourceKey: _requiredString(json, 'sourceKey'),
    );
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Certificate data is missing "$key".');
  }
  return value;
}

class CertificateProgress {
  final String courseName;
  final int completedLessons;
  final int totalLessons;

  const CertificateProgress({
    required this.courseName,
    required this.completedLessons,
    required this.totalLessons,
  });

  bool get isCompleted =>
      totalLessons > 0 && completedLessons >= totalLessons;

  double get fraction =>
      totalLessons == 0 ? 0 : completedLessons / totalLessons;
}

class CertificateStore {
  CertificateStore._();

  static final CertificateStore instance = CertificateStore._();
  static const _storageKey = 'learnhub_earned_certificates_v1';
  static const assessmentPassPercent = 70;

  final ValueNotifier<List<LearnHubCertificate>> certificates =
      ValueNotifier<List<LearnHubCertificate>>(
        const <LearnHubCertificate>[],
      );
  bool _isLoaded = false;

  Future<void> load() async {
    if (_isLoaded) {
      return;
    }
    final preferences = await SharedPreferences.getInstance();
    final serialized = preferences.getString(_storageKey);
    if (serialized != null) {
      final decoded = jsonDecode(serialized);
      if (decoded is! List) {
        throw const FormatException('Saved certificates are not a JSON list.');
      }
      certificates.value = decoded.map((entry) {
        if (entry is! Map<String, dynamic>) {
          throw const FormatException('A saved certificate is malformed.');
        }
        return LearnHubCertificate.fromJson(entry);
      }).toList();
    }
    _isLoaded = true;
  }

  Future<LearnHubCertificate?> awardCourseIfComplete({
    required String courseName,
    required String learnerName,
    required Iterable<String> requiredLessonIds,
    required Set<String> completedLessonIds,
  }) async {
    final requiredIds = requiredLessonIds.toSet();
    if (requiredIds.isEmpty || !completedLessonIds.containsAll(requiredIds)) {
      return null;
    }
    await load();
    final sourceKey = 'course:$courseName';
    final existing = _findBySource(sourceKey);
    if (existing != null) {
      return existing;
    }
    return _saveNewCertificate(
      title: '$courseName Course Certificate',
      courseName: courseName,
      learnerName: learnerName,
      kind: CertificateKind.course,
      sourceKey: sourceKey,
    );
  }

  Future<LearnHubCertificate?> awardAssessmentIfPassed({
    required String courseName,
    required String assessmentName,
    required String learnerName,
    required int score,
    required int totalQuestions,
  }) async {
    if (totalQuestions <= 0 ||
        score * 100 < totalQuestions * assessmentPassPercent) {
      return null;
    }
    await load();
    final sourceKey = 'assessment:$courseName:$assessmentName';
    final existing = _findBySource(sourceKey);
    if (existing != null) {
      return existing;
    }
    return _saveNewCertificate(
      title: '$assessmentName Assessment Certificate',
      courseName: '$courseName - $assessmentName',
      learnerName: learnerName,
      kind: CertificateKind.assessment,
      sourceKey: sourceKey,
    );
  }

  Future<void> renameLearner({
    required String previousName,
    required String newName,
  }) async {
    final oldName = previousName.trim();
    final updatedName = newName.trim();
    if (oldName.isEmpty || updatedName.isEmpty || oldName == updatedName) {
      return;
    }
    await load();
    var changed = false;
    final updated = certificates.value.map((certificate) {
      if (certificate.learnerName != oldName) {
        return certificate;
      }
      changed = true;
      return certificate.copyWith(learnerName: updatedName);
    }).toList();
    if (changed) {
      await _saveCertificates(updated);
    }
  }

  Future<LearnHubCertificate> _saveNewCertificate({
    required String title,
    required String courseName,
    required String learnerName,
    required CertificateKind kind,
    required String sourceKey,
  }) async {
    final now = DateTime.now();
    final slug = courseName
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    final certificateSlug = slug.isEmpty ? 'COURSE' : slug;
    final certificate = LearnHubCertificate(
      id: 'LH-${certificateSlug.substring(0, certificateSlug.length > 8 ? 8 : certificateSlug.length)}-${now.millisecondsSinceEpoch.toRadixString(36).toUpperCase()}',
      title: title,
      courseName: courseName,
      learnerName: learnerName.trim().isEmpty
          ? 'Guest learner'
          : learnerName.trim(),
      completedAt: now,
      kind: kind,
      sourceKey: sourceKey,
    );
    await _saveCertificates([...certificates.value, certificate]);
    return certificate;
  }

  LearnHubCertificate? _findBySource(String sourceKey) {
    for (final certificate in certificates.value) {
      if (certificate.sourceKey == sourceKey) {
        return certificate;
      }
    }
    return null;
  }

  Future<void> _saveCertificates(
    List<LearnHubCertificate> values,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final didSave = await preferences.setString(
      _storageKey,
      jsonEncode(values.map((certificate) => certificate.toJson()).toList()),
    );
    if (!didSave) {
      throw Exception('Could not save your certificate.');
    }
    certificates.value = List<LearnHubCertificate>.unmodifiable(values);
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.remove(_storageKey)) {
      throw Exception('Could not remove saved certificates.');
    }
    certificates.value = const <LearnHubCertificate>[];
    _isLoaded = true;
  }

  void resetInMemory() {
    certificates.value = const <LearnHubCertificate>[];
    _isLoaded = false;
  }
}
