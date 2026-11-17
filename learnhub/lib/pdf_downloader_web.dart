import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

Future<void> downloadPdfBytes(Uint8List bytes, String filename) async {
  final blob = web.Blob(
    <web.BlobPart>[bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'application/pdf'),
  );
  final url = web.URL.createObjectURL(blob);
  final link = web.document.createElement('a') as web.HTMLAnchorElement;
  link
    ..href = url
    ..download = filename
    ..click();
  web.URL.revokeObjectURL(url);
}
