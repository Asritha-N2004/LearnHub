import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'certificate_store.dart';

Future<Uint8List> createCertificatePdf(LearnHubCertificate certificate) async {
  final document = pw.Document();
  document.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(28),
      build: (context) => pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.blue900, width: 3),
        ),
        padding: const pw.EdgeInsets.all(28),
        child: pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.amber700, width: 1.5),
          ),
          padding: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 28),
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                children: [
                  pw.Text(
                    'LEARNHUB',
                    style: pw.TextStyle(
                      color: PdfColors.blue900,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    'CERTIFICATE OF COMPLETION',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      color: PdfColors.amber800,
                      fontSize: 25,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'This certificate is proudly presented to',
                    style: const pw.TextStyle(
                      color: PdfColors.grey700,
                      fontSize: 13,
                    ),
                  ),
                  pw.SizedBox(height: 9),
                  pw.Text(
                    _pdfSafe(certificate.learnerName),
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      color: PdfColors.blue900,
                      fontSize: 30,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 11),
                  pw.Text(
                    'for successfully completing',
                    style: const pw.TextStyle(
                      color: PdfColors.grey700,
                      fontSize: 13,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    _pdfSafe(certificate.courseName),
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      color: PdfColors.blueGrey800,
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'COMPLETION DATE',
                        style: pw.TextStyle(
                          color: PdfColors.grey700,
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(_formatDate(certificate.completedAt)),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'CERTIFICATE ID: ${certificate.id}',
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(
                        width: 150,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(color: PdfColors.blueGrey700),
                          ),
                        ),
                        padding: const pw.EdgeInsets.only(bottom: 5),
                        child: pw.Text(
                          'LearnHub Academic Team',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'AUTHORIZED SIGNATURE',
                        style: const pw.TextStyle(
                          color: PdfColors.grey700,
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return document.save();
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String _pdfSafe(String text) {
  return text
      .replaceAll(RegExp(r'[^\x00-\x7F]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
