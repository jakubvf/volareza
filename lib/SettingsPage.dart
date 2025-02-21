import 'package:flutter/material.dart';

import 'main.dart';

class SettingsPage extends StatefulWidget {
  final SettingsNotifier settingsNotifier;

  const SettingsPage({
    super.key,
    required this.settingsNotifier,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;

  final List<ColorSeedOption> colorOptions = [
    ColorSeedOption('Tmavě fialová', Color(Colors.deepPurple.toARGB32())),
    ColorSeedOption('Indigo', Color(Colors.indigo.toARGB32())),
    ColorSeedOption('Modrá', Color(Colors.blue.toARGB32())),
    ColorSeedOption('Modrozelená', Color(Colors.teal.toARGB32())),
    ColorSeedOption('Zelená', Color(Colors.green.toARGB32())),
    ColorSeedOption('Oranžová', Color(Colors.orange.toARGB32())),
    ColorSeedOption('Žlutá', Color(Colors.yellow.toARGB32())),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nastavení'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // Default eatery
          Card(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Oblíbená jídelna',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ListTile(
                  title: const Text('Jídelna'),
                  onTap: _showDefaultEateryDialog,
                )
              ])),
          // Appearance
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Vzhled aplikace',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ListTile(
                  title: const Text('Světlý a tmavý vzhled'),
                  subtitle: Text(_getThemeText()),
                  onTap: _showThemeDialog,
                ),
                ListTile(
                  title: const Text('Barvné rozvržení'),
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
                    'Oznámení',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                SwitchListTile(
                  title: const Text('Zapnout oznámení'),
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
    switch (widget.settingsNotifier.themeMode) {
      case ThemeMode.system:
        return 'Podle systému';
      case ThemeMode.light:
        return 'Vždy světlý';
      case ThemeMode.dark:
        return 'Vždy tmavý';
    }
  }

  String _getColorText() {
    final currentColor = widget.settingsNotifier.colorSeed;
    final option = colorOptions.firstWhere(
      (option) => option.color == currentColor,
      orElse: () => ColorSeedOption('Vlastní', currentColor),
    );
    return option.name;
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Zvolte vzhled'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile<ThemeMode>(
                title: const Text('Podle systému'),
                value: ThemeMode.system,
                groupValue: widget.settingsNotifier.themeMode,
                onChanged: (ThemeMode? value) async {
                  await widget.settingsNotifier.setThemeMode(value!);
                  if (mounted) Navigator.of(context).pop();
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Vždy světlý'),
                value: ThemeMode.light,
                groupValue: widget.settingsNotifier.themeMode,
                onChanged: (ThemeMode? value) async {
                  await widget.settingsNotifier.setThemeMode(value!);
                  if (mounted) Navigator.of(context).pop();
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Vždy tmavý'),
                value: ThemeMode.dark,
                groupValue: widget.settingsNotifier.themeMode,
                onChanged: (ThemeMode? value) async {
                  await widget.settingsNotifier.setThemeMode(value!);
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
          title: const Text('Zvolte barvu'),
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
                  groupValue: widget.settingsNotifier.colorSeed,
                  onChanged: (Color? value) async {
                    await widget.settingsNotifier.setColorSeed(value!);
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

  void _showDefaultEateryDialog() {}
}

class ColorSeedOption {
  final String name;
  final Color color;

  ColorSeedOption(this.name, this.color);
}
