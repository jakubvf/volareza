import 'package:flutter/material.dart';
import 'package:volareza/json_parsing.dart';

import 'ApiClient.dart';
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
  String _facilityName = 'Načítám...'; // Initial state while loading

  Facility? _facility;

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
  void initState() {
    super.initState();
    _loadFacility();
  }

  Future<void> _loadFacility() async {
    try {
      _facility = await ApiClient.instance.getFacility();

      // Set default eatery if not set
      if (widget.settingsNotifier.defaultEatery == null) {
        widget.settingsNotifier.setDefaultEatery(_facility!.eateries.first.id);
      }

      // Find the default eatery inside preferences
      final eatery = _facility!.eateries
          .where((eatery) => eatery.id == widget.settingsNotifier.defaultEatery)
          .first;

      if (!mounted) return;
      setState(() {
        _facilityName = eatery.name;
      });
    } catch (e) {
      // Handle error appropriately, e.g., show an error message
      print('Error loading facility: $e');

      if (!mounted) return;
      setState(() {
        _facilityName = 'Chyba načítání'; // Display error message
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    'Výchozí jídelna',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                description(
                    'Vyberte jídelnu, kterou používáte nejčastěji. Aplikace si ji zapamatuje a automaticky ji zobrazí jako první, takže nebudete muset pokaždé vybírat ručně.'),
                ListTile(
                  title: Text(_facilityName),
                  leading: const Icon(Icons.restaurant),
                  onTap: _showDefaultEateryDialog,
                )
              ])),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Víkendové obědy',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                description('Pokud objednáváte obědy i o víkendech, můžete si nechat zobrazit i nabídku na sobotu a neděli.'),
                SwitchListTile(
                  title: widget.settingsNotifier.showWeekends
                      ? Text('Zobrazovat')
                      : Text('Nezobrazovat'),
                  value: widget.settingsNotifier.showWeekends,
                  secondary: const Icon(Icons.calendar_today),
                  onChanged: (bool value) {
                    setState(() {
                      widget.settingsNotifier.setShowWeekends(value);
                    });
                  },
                ),
              ],
            ),
          ),
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
                description(
                    'Přizpůsobte si vzhled aplikace dle svých preferencí. Vyberte si mezi světlým, tmavým režimem a přizpůsobte si barevné schéma.'),
                ListTile(
                  title: const Text('Světlý a tmavý vzhled'),
                  subtitle: Text(_getThemeText()),
                  onTap: _showThemeDialog,
                  leading: const Icon(Icons.format_paint),
                ),
                ListTile(
                  title: const Text('Barvné rozvržení'),
                  subtitle: Text(_getColorText()),
                  onTap: _showColorDialog,
                  leading: const Icon(Icons.color_lens),
                ),
              ],
            ),
          ),
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

  void _showDefaultEateryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Zvolte oblíbenou jídelnu'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _facility!.eateries.map((eatery) {
                return RadioListTile<String>(
                  title: Text(eatery.name),
                  value: eatery.id,
                  groupValue: widget.settingsNotifier.defaultEatery,
                  onChanged: (String? value) async {
                    await widget.settingsNotifier.setDefaultEatery(value!);
                    setState(() {
                      _facilityName = eatery.name;
                    });
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

  Widget description(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
    );
  }
}

class ColorSeedOption {
  final String name;
  final Color color;

  ColorSeedOption(this.name, this.color);
}
