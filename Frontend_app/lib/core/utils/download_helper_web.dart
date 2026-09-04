import 'dart:js_interop';

@JS('downloadApk')
external void _downloadApkJs();

void triggerApkDownload() {
  try {
    _downloadApkJs();
  } catch (_) {}
}
