import 'package:flutter/material.dart';

import 'main.dart';

class SettingsPage extends StatefulWidget {
  final ThemeNotifier themeNotifier;

  const SettingsPage({
    super.key,
    required this.themeNotifier,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;

  final List<ColorSeedOption> colorOptions = [
    ColorSeedOption('Deep Purple', Colors.deepPurple),
    ColorSeedOption('Indigo', Colors.indigo),
    ColorSeedOption('Blue', Colors.blue),
    ColorSeedOption('Teal', Colors.teal),
    ColorSeedOption('Green', Colors.green),
    ColorSeedOption('Orange', Colors.orange),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ListTile(
                  title: const Text('Theme'),
                  subtitle: Text(_getThemeText()),
                  onTap: _showThemeDialog,
                ),
                ListTile(
                  title: const Text('Color Scheme'),
                  subtitle: Text(_getColorText()),
                  onTap: _showColorDialog,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  value: _notificationsEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeText() {
    switch (widget.themeNotifier.themeMode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  String _getColorText() {
    final currentColor = widget.themeNotifier.colorSeed;
    final option = colorOptions.firstWhere(
          (option) => option.color == currentColor,
      orElse: () => ColorSeedOption('Custom', currentColor),
    );
    return option.name;
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile<ThemeMode>(
                title: const Text('System'),
                value: ThemeMode.system,
                groupValue: widget.themeNotifier.themeMode,
                onChanged: (ThemeMode? value) async {
                  await widget.themeNotifier.setThemeMode(value!);
                  if (mounted) Navigator.of(context).pop();
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Light'),
                value: ThemeMode.light,
                groupValue: widget.themeNotifier.themeMode,
                onChanged: (ThemeMode? value) async {
                  await widget.themeNotifier.setThemeMode(value!);
                  if (mounted) Navigator.of(context).pop();
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark'),
                value: ThemeMode.dark,
                groupValue: widget.themeNotifier.themeMode,
                onChanged: (ThemeMode? value) async {
                  await widget.themeNotifier.setThemeMode(value!);
                  if (mounted) Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showColorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Color Scheme'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: colorOptions.map((option) {
                return RadioListTile<Color>(
                  title: Text(option.name),
                  secondary: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: option.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  value: option.color,
                  groupValue: widget.themeNotifier.colorSeed,
                  onChanged: (Color? value) async {
                    await widget.themeNotifier.setColorSeed(value!);
                    if (mounted) Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class ColorSeedOption {
  final String name;
  final Color color;

  ColorSeedOption(this.name, this.color);
}
