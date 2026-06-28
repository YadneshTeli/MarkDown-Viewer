import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:open_filex/open_filex.dart';

class ReleaseInfo {
  final String tagName;
  final String htmlUrl;
  final String body;
  final String? apkDownloadUrl;

  ReleaseInfo({
    required this.tagName,
    required this.htmlUrl,
    required this.body,
    this.apkDownloadUrl,
  });
}

class UpdateService {
  static const String _owner = 'YadneshTeli';
  static const String _repo = 'MarkDown-Viewer';

  /// Checks if an update is available on GitHub.
  /// Returns [ReleaseInfo] if a newer version is found, or null otherwise.
  Future<ReleaseInfo?> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersionStr = packageInfo.version;
      final currentVersion = Version.parse(currentVersionStr);

      final url = Uri.parse('https://api.github.com/repos/$_owner/$_repo/releases/latest');
      final response = await http.get(
        url,
        headers: {'User-Agent': 'nusta_md_updater'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final latestTag = data['tag_name'] as String;
        final cleanTag = latestTag.replaceAll(RegExp(r'^v'), '');
        final latestVersion = Version.parse(cleanTag);

        if (latestVersion > currentVersion) {
          final assets = data['assets'] as List<dynamic>;
          String? apkUrl;
          for (final asset in assets) {
            final name = asset['name'] as String;
            if (name.endsWith('.apk')) {
              apkUrl = asset['browser_download_url'] as String;
              break;
            }
          }

          return ReleaseInfo(
            tagName: latestTag,
            htmlUrl: data['html_url'] as String,
            body: data['body'] as String? ?? 'No release notes provided.',
            apkDownloadUrl: apkUrl,
          );
        }
      }
    } catch (e) {
      debugPrint('Failed to check for updates: $e');
    }
    return null;
  }

  /// Downloads the APK and calls [onProgress] with values between 0.0 and 1.0.
  /// Returns the file path of the downloaded APK.
  Future<File> downloadApk(String url, Function(double progress) onProgress) async {
    if (kIsWeb || !Platform.isAndroid) {
      throw UnsupportedError('Direct APK download is only supported on Android.');
    }

    final client = http.Client();
    final request = http.Request('GET', Uri.parse(url));
    final response = await client.send(request);

    if (response.statusCode != 200) {
      throw HttpException('Failed to download file: server returned ${response.statusCode}');
    }

    final totalBytes = response.contentLength ?? 0;
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/app-update.apk');
    if (await file.exists()) {
      await file.delete();
    }

    final sink = file.openWrite();
    int downloadedBytes = 0;

    await for (final chunk in response.stream) {
      sink.add(chunk);
      downloadedBytes += chunk.length;
      if (totalBytes > 0) {
        onProgress(downloadedBytes / totalBytes);
      }
    }

    await sink.close();
    client.close();
    return file;
  }

  /// Opens the downloaded APK to launch the Android system installer prompt.
  Future<OpenResult> installApk(File file) async {
    if (kIsWeb || !Platform.isAndroid) {
      throw UnsupportedError('APK installation is only supported on Android.');
    }
    return OpenFilex.open(file.path, type: 'application/vnd.android.package-archive');
  }
}
