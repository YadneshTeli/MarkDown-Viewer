import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final theme = Theme.of(context);

    // Read font size from Hive
    final settingsBox = Hive.box(AppConstants.settingsBox);
    final fontSize =
        settingsBox.get(AppConstants.fontSizeKey, defaultValue: 16.0) as double;

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
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
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
              selected: {themeMode},
              onSelectionChanged: (set) {
                themeNotifier.setThemeMode(set.first);
              },
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
                settingsBox.put(AppConstants.fontSizeKey, value);
                // Force rebuild
                (context as Element).markNeedsBuild();
              },
            ),
          ),

          const Divider(indent: 16, endIndent: 16, height: 32),

          // ─── About Section ───
          _sectionHeader(theme, 'About'),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('MD Viewer'),
            subtitle: Text('Version ${AppConstants.appVersion}'),
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
}
