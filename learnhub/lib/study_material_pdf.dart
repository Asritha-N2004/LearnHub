import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;

class StudyMaterialChapter {
  final String title;
  final String level;
  final String introduction;
  final String explanation;
  final List<String> concepts;
  final String example;
  final String expectedOutput;
  final String applications;
  final List<String> exercises;
  final String assignment;

  const StudyMaterialChapter({
    required this.title,
    required this.level,
    required this.introduction,
    required this.explanation,
    required this.concepts,
    required this.example,
    required this.expectedOutput,
    required this.applications,
    required this.exercises,
    required this.assignment,
  });
}

String _pdfSafeText(String text) {
  return text
      .replaceAll('’', "'")
      .replaceAll('‘', "'")
      .replaceAll('“', '"')
      .replaceAll('”', '"')
      .replaceAll('–', '-')
      .replaceAll('—', '-')
      .replaceAll('•', '-')
      .replaceAll(RegExp(r'[^\x00-\x7F]'), '');
}

pw.Widget _pdfBullet(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('- '),
        pw.Expanded(child: pw.Text(_pdfSafeText(text))),
      ],
    ),
  );
}

Future<Uint8List> createStudyMaterialPdf({
  required String courseTitle,
  required String introduction,
  required List<String> objectives,
  required List<StudyMaterialChapter> chapters,
}) async {
  final document = pw.Document();
  document.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Header(level: 0, text: _pdfSafeText(courseTitle)),
        pw.Paragraph(text: _pdfSafeText(introduction)),
        pw.Header(level: 1, text: 'Learning Objectives'),
        ...objectives.map(_pdfBullet),
        for (final chapter in chapters) ...[
          pw.Header(
            level: 1,
            text: _pdfSafeText('${chapter.level}: ${chapter.title}'),
          ),
          pw.Paragraph(text: _pdfSafeText(chapter.introduction)),
          pw.Paragraph(text: _pdfSafeText(chapter.explanation)),
          pw.Header(level: 2, text: 'Important Concepts'),
          ...chapter.concepts.map(_pdfBullet),
          pw.Header(level: 2, text: 'Practical Example'),
          pw.Text(_pdfSafeText(chapter.example)),
          pw.Paragraph(
            text: _pdfSafeText('Expected output: ${chapter.expectedOutput}'),
          ),
          pw.Paragraph(
            text: _pdfSafeText(
              'Real-world applications: ${chapter.applications}',
            ),
          ),
          pw.Header(level: 2, text: 'Hands-on Exercises'),
          ...chapter.exercises.map(_pdfBullet),
          pw.Header(level: 2, text: 'Assignment'),
          pw.Paragraph(text: _pdfSafeText(chapter.assignment)),
        ],
      ],
    ),
  );
  return document.save();
}
