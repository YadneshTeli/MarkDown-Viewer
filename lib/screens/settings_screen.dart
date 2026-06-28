import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/service_providers.dart';
import '../providers/theme_provider.dart';
import '../providers/font_size_provider.dart';
import '../services/update_service.dart';
import '../utils/constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final fontSize = ref.watch(fontSizeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // ─── Appearance Section ───
          _sectionHeader(theme, 'Appearance'),

          // Theme mode
          ListTile(
            leading: Icon(themeNotifier.icon),
            title: const Text('Theme'),
            subtitle: Text(themeNotifier.label),
            trailing: SegmentedButton<ThemeMode>(
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              selected: {themeMode},
              onSelectionChanged: (set) {
                themeNotifier.setThemeMode(set.first);
              },
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto, size: 18),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode, size: 18),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode, size: 18),
                ),
              ],
            ),
          ),

          const Divider(indent: 16, endIndent: 16),

          // Font size
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Font Size'),
            subtitle: Text('${fontSize.toInt()}px'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Slider(
              value: fontSize,
              min: 12,
              max: 24,
              divisions: 12,
              label: '${fontSize.toInt()}px',
              onChanged: (value) {
                ref.read(fontSizeProvider.notifier).setFontSize(value);
              },
            ),
          ),

          const Divider(indent: 16, endIndent: 16, height: 32),

          // ─── About Section ───
          _sectionHeader(theme, 'About'),

          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.hasData ? snapshot.data!.version : AppConstants.appVersion;
              return ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('MD Viewer'),
                subtitle: Text('Version $version'),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.system_update),
            title: const Text('Check for Updates'),
            subtitle: const Text('Check GitHub for the latest version'),
            onTap: () => _handleCheckForUpdates(context, ref),
          ),

          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Built with'),
            subtitle: const Text('Flutter • Riverpod • Hive • markdown_widget'),
          ),

          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Developer'),
            subtitle: const Text('Yadnesh Teli'),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Future<void> _handleCheckForUpdates(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Checking for updates...'),
              ],
            ),
          ),
        ),
      ),
    );

    final updateService = ref.read(updateServiceProvider);
    final release = await updateService.checkForUpdate();

    if (context.mounted) {
      Navigator.pop(context); // Close loading dialog
    }

    if (release == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('App is up to date!')),
        );
      }
      return;
    }

    if (context.mounted) {
      _showUpdatePromptDialog(context, ref, release);
    }
  }

  void _showUpdatePromptDialog(BuildContext context, WidgetRef ref, ReleaseInfo release) {
    final canDirectDownload = !kIsWeb && Platform.isAndroid && release.apkDownloadUrl != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New Version ${release.tagName} Available'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('What\'s New:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    release.body,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final uri = Uri.parse(release.htmlUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('Open Page'),
          ),
          if (canDirectDownload)
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _startDirectDownload(context, ref, release.apkDownloadUrl!);
              },
              child: const Text('Update Now'),
            ),
        ],
      ),
    );
  }

  void _startDirectDownload(BuildContext context, WidgetRef ref, String url) {
    final updateService = ref.read(updateServiceProvider);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        double progress = 0.0;
        bool started = false;
        
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            if (!started) {
              started = true;
              Future.microtask(() async {
                try {
                  final file = await updateService.downloadApk(url, (p) {
                    setState(() {
                      progress = p;
                    });
                  });
                  
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                  
                  await updateService.installApk(file);
                } catch (e) {
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to download update: $e')),
                    );
                  }
                }
              });
            }
            
            return AlertDialog(
              title: const Text('Downloading Update'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Downloading the latest APK...'),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 8),
                  Text('${(progress * 100).toInt()}%'),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
