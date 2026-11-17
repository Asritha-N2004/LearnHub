import 'package:material_ui/material_ui.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'certificate_pdf.dart';
import 'certificate_store.dart';

const Color _certificateBlue = Color(0xFF173B75);
const Color _certificateGold = Color(0xFFC39134);

class CertificatesPage extends StatefulWidget {
  final List<CertificateProgress> courseProgress;

  const CertificatesPage({super.key, required this.courseProgress});

  @override
  State<CertificatesPage> createState() => _CertificatesPageState();
}

class _CertificatesPageState extends State<CertificatesPage> {
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    try {
      await CertificateStore.instance.load();
    } on Exception catch (error) {
      if (mounted) {
        setState(() => _loadError = error.toString());
      }
    }
  }

  void _openCertificate(LearnHubCertificate certificate) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CertificateViewPage(certificate: certificate),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Certificates')),
      body: SafeArea(
        child: ValueListenableBuilder<List<LearnHubCertificate>>(
          valueListenable: CertificateStore.instance.certificates,
          builder: (context, storedCertificates, child) {
            final earned = storedCertificates.toList()
              ..sort(
                (a, b) => b.completedAt.compareTo(a.completedAt),
              );
            final inProgress = widget.courseProgress
                .where(
                  (progress) => !earned.any(
                    (certificate) =>
                        certificate.kind == CertificateKind.course &&
                        certificate.courseName == progress.courseName,
                  ),
                )
                .toList();
            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth > 900
                    ? 900.0
                    : constraints.maxWidth;
                return Center(
                  child: SizedBox(
                    width: width,
                    child: ListView(
                      padding: const EdgeInsets.all(18),
                      children: [
                        const Text(
                          'Your achievements',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Certificates are issued after all course lessons are complete or an assessment is passed with at least ${CertificateStore.assessmentPassPercent}%.',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        if (_loadError != null) ...[
                          const SizedBox(height: 12),
                          _CertificateErrorBanner(
                            message: _loadError!,
                            onRetry: _loadCertificates,
                          ),
                        ],
                        const SizedBox(height: 18),
                        if (earned.isEmpty)
                          const _EmptyCertificateState()
                        else ...[
                          Text(
                            'Earned certificates (${earned.length})',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          for (final certificate in earned)
                            _EarnedCertificateCard(
                              certificate: certificate,
                              onView: () => _openCertificate(certificate),
                            ),
                        ],
                        const SizedBox(height: 22),
                        Text(
                          'Certificate progress (${inProgress.length})',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (inProgress.isEmpty)
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(18),
                              child: Text(
                                'All course certificates have been earned. Great work!',
                              ),
                            ),
                          )
                        else
                          for (final progress in inProgress)
                            _CertificateProgressCard(progress: progress),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _EmptyCertificateState extends StatelessWidget {
  const _EmptyCertificateState();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.workspace_premium_outlined,
              size: 56,
              color: _certificateGold,
            ),
            const SizedBox(height: 12),
            const Text(
              'Your first certificate is waiting',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete every lesson in a course or pass an assessment to earn a verified LearnHub certificate. In-progress learning is shown below; no certificate is created early.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _EarnedCertificateCard extends StatelessWidget {
  final LearnHubCertificate certificate;
  final VoidCallback onView;

  const _EarnedCertificateCard({
    required this.certificate,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFFF3D7),
          child: Icon(Icons.workspace_premium, color: _certificateGold),
        ),
        title: Text(
          certificate.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            '${certificate.courseName}\n'
            '${certificate.learnerName} • ${_formatDate(certificate.completedAt)}\n'
            'ID: ${certificate.id}',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        isThreeLine: true,
        trailing: const Chip(
          avatar: Icon(Icons.check_circle, size: 16, color: Colors.green),
          label: Text('Completed'),
          visualDensity: VisualDensity.compact,
        ),
        onTap: onView,
      ),
    );
  }
}

class _CertificateProgressCard extends StatelessWidget {
  final CertificateProgress progress;

  const _CertificateProgressCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.school_outlined, color: _certificateBlue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    progress.courseName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Chip(
                  label: Text('In Progress'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: progress.fraction),
            const SizedBox(height: 7),
            Text(
              '${progress.completedLessons}/${progress.totalLessons} lessons complete • Finish the course to earn its certificate.',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _CertificateErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CertificateErrorBanner({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: ListTile(
        title: const Text('Certificate data could not be loaded.'),
        subtitle: Text(message),
        trailing: IconButton(
          tooltip: 'Retry',
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
        ),
      ),
    );
  }
}

class CertificateViewPage extends StatelessWidget {
  final LearnHubCertificate certificate;

  const CertificateViewPage({super.key, required this.certificate});

  String get _filename =>
      'learnhub_certificate_${certificate.id.toLowerCase()}.pdf';

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _download(BuildContext context) async {
    try {
      final bytes = await createCertificatePdf(certificate);
      await Printing.layoutPdf(
        name: _filename,
        format: PdfPageFormat.a4.landscape,
        onLayout: (_) async => bytes,
      );
      if (context.mounted) {
        _showMessage(context, 'Certificate PDF is ready to save or print.');
      }
    } on Exception catch (error) {
      if (context.mounted) {
        _showMessage(context, 'Could not create certificate PDF: $error');
      }
    }
  }

  Future<void> _share(BuildContext context) async {
    try {
      final bytes = await createCertificatePdf(certificate);
      await Printing.sharePdf(bytes: bytes, filename: _filename);
    } on Exception catch (error) {
      if (context.mounted) {
        _showMessage(context, 'Could not share certificate: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Certificate')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth > 900
                ? 900.0
                : constraints.maxWidth;
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: SizedBox(
                  width: width,
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 1.414,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: _certificateBlue,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 16,
                                offset: const Offset(0, 7),
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _certificateGold,
                                width: 1.5,
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: SizedBox(
                                width: 560,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'LEARNHUB',
                                      style: TextStyle(
                                        color: _certificateBlue,
                                        letterSpacing: 5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    const Text(
                                      'CERTIFICATE OF COMPLETION',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _certificateGold,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    Text(
                                      certificate.learnerName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: _certificateBlue,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text('has successfully completed'),
                                    const SizedBox(height: 8),
                                    Text(
                                      certificate.courseName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Wrap(
                                      alignment: WrapAlignment.spaceBetween,
                                      spacing: 20,
                                      runSpacing: 10,
                                      children: [
                                        Text(
                                          'Date: ${_formatDate(certificate.completedAt)}',
                                        ),
                                        Text('Certificate ID: ${certificate.id}'),
                                      ],
                                    ),
                                    const SizedBox(height: 22),
                                    const Text(
                                      '____________________________\nLearnHub Academic Team',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(height: 1.5),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          FilledButton.icon(
                            onPressed: () => _download(context),
                            icon: const Icon(Icons.download_outlined),
                            label: const Text('Download Certificate as PDF'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _share(context),
                            icon: const Icon(Icons.share_outlined),
                            label: const Text('Share Certificate'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
