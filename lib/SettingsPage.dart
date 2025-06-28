import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ApiClient.dart';
import 'models/facility.dart';
import 'settings/settings_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

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

      final settings = SettingsProvider.of(context);
      
      // Set default eatery if not set
      if (settings.defaultEatery == null) {
        settings.setDefaultEatery(_facility!.eateries.first.id);
      }

      // Find the default eatery inside preferences
      final eatery = _facility!.eateries
          .where((eatery) => eatery.id == settings.defaultEatery)
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
                Builder(
                  builder: (context) {
                    final settings = SettingsProvider.of(context);
                    return SwitchListTile(
                      title: settings.showWeekends
                          ? Text('Zobrazovat')
                          : Text('Nezobrazovat'),
                      value: settings.showWeekends,
                      secondary: const Icon(Icons.calendar_today),
                      onChanged: (bool value) {
                        setState(() {
                          settings.setShowWeekends(value);
                        });
                      },
                    );
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
          // About app
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'O aplikaci',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                description(
                    'Mobilní aplikace pro objednávání obědů v jídelnách Univerzity obrany. Nabízí intuitivní rozhraní pro správu jídelníčku a objednávek přímo z mobilního telefonu.'),
                
                // App version
                FutureBuilder<String>(
                  future: _getAppVersion(),
                  builder: (context, snapshot) {
                    return ListTile(
                      title: const Text('Verze aplikace'),
                      subtitle: Text(snapshot.data ?? 'Načítání...'),
                      leading: const Icon(Icons.info_outline),
                      onTap: () => _copyVersionToClipboard(snapshot.data),
                    );
                  },
                ),
                
                // Publisher
                const ListTile(
                  title: Text('Vydavatel'),
                  subtitle: Text('Univerzita obrany'),
                  leading: Icon(Icons.school),
                ),
                
                // Developer
                const ListTile(
                  title: Text('Vývojář'),
                  subtitle: Text('Jakub Václav Flasar'),
                  leading: Icon(Icons.person),
                ),
                
                // Contact
                ListTile(
                  title: const Text('Kontakt'),
                  subtitle: const Text('jakubvaclav.flasar@unob.cz'),
                  leading: const Icon(Icons.email),
                  onTap: () => _copyToClipboard('jakubvaclav.flasar@unob.cz', 'Email zkopírován do schránky'),
                ),
                
                // Privacy info
                ListTile(
                  title: const Text('Ochrana osobních údajů'),
                  subtitle: const Text('Přihlašovací údaje jsou uloženy pouze v zařízení'),
                  leading: const Icon(Icons.privacy_tip),
                  onTap: _showPrivacyDialog,
                ),
                
                // TODO: Implement feedback
                ListTile(
                  title: const Text('Zpětná vazba'),
                  subtitle: const Text('Nahlásit problém nebo návrh'),
                  leading: const Icon(Icons.feedback),
                  onTap: _showFeedbackDialog,
                ),
                
                // Open source
                ListTile(
                  title: const Text('Open Source'),
                  subtitle: const Text('Zobrazit použité knihovny'),
                  leading: const Icon(Icons.code),
                  onTap: _showOpenSourceDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeText() {
    final settings = SettingsProvider.of(context);
    switch (settings.themeMode) {
      case ThemeMode.system:
        return 'Podle systému';
      case ThemeMode.light:
        return 'Vždy světlý';
      case ThemeMode.dark:
        return 'Vždy tmavý';
    }
  }

  String _getColorText() {
    final settings = SettingsProvider.of(context);
    final currentColor = settings.colorSeed;
    final option = colorOptions.firstWhere(
      (option) => option.color == currentColor,
      orElse: () => ColorSeedOption('Vlastní', currentColor),
    );
    return option.name;
  }

  void _showThemeDialog() {
    final settings = SettingsProvider.of(context);
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
                groupValue: settings.themeMode,
                onChanged: (ThemeMode? value) async {
                  await settings.setThemeMode(value!);
                  if (mounted) Navigator.of(context).pop();
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Vždy světlý'),
                value: ThemeMode.light,
                groupValue: settings.themeMode,
                onChanged: (ThemeMode? value) async {
                  await settings.setThemeMode(value!);
                  if (mounted) Navigator.of(context).pop();
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Vždy tmavý'),
                value: ThemeMode.dark,
                groupValue: settings.themeMode,
                onChanged: (ThemeMode? value) async {
                  await settings.setThemeMode(value!);
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
    final settings = SettingsProvider.of(context);
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
                  groupValue: settings.colorSeed,
                  onChanged: (Color? value) async {
                    await settings.setColorSeed(value!);
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
    final settings = SettingsProvider.of(context);
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
                  groupValue: settings.defaultEatery,
                  onChanged: (String? value) async {
                    await settings.setDefaultEatery(value!);
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

  Future<String> _getAppVersion() async {
    final packageInfo = await _getPackageInfo();
    return '${packageInfo['version']}+${packageInfo['buildNumber']}';
  }

  Future<Map<String, String>> _getPackageInfo() async {
    // In Flutter, we need to use a different approach to get version info
    // since package_info requires additional setup
    return {'version': '1.0.0', 'buildNumber': '1'};
  }

  void _copyVersionToClipboard(String? version) {
    if (version != null) {
      _copyToClipboard(version, 'Verze zkopírována do schránky');
    }
  }
  
  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ochrana osobních údajů'),
          content: const SingleChildScrollView(
            child: Text(
              'Vaše přihlašovací údaje jsou uloženy pouze v tomto zařízení pomocí zabezpečeného úložiště. '
              'Údaje jsou odesílány pouze na oficiální služby:\n\n'
              '• https://unob.jidelny-vlrz.cz\n'
              '• https://adfs.unob.cz\n\n'
              'Aplikace nesbírá ani neodesílá žádné další osobní údaje třetím stranám.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Rozumím'),
            ),
          ],
        );
      },
    );
  }
  
  void _showFeedbackDialog() {
    // TODO: Implement feedback
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Zpětná vazba'),
          content: const Text(
            'Funkce zpětné vazby bude implementována v příští verzi aplikace. '
            'Zatím můžete kontaktovat vývojáře na emailu jakubvaclav.flasar@unob.cz',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Rozumím'),
            ),
          ],
        );
      },
    );
  }
  
  void _showOpenSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Open Source knihovny'),
          content: const SingleChildScrollView(
            child: Text(
              'Tato aplikace používá následující open source knihovny:\n\n'
              '• Flutter - UI framework\n'
              '• http - HTTP klient\n'
              '• crypto - Kryptografické funkce\n'
              '• flutter_secure_storage - Zabezpečené úložiště\n'
              '• shared_preferences - Ukládání nastavení\n'
              '• drift - Databáze ORM\n'
              '• table_calendar - Kalendářové komponenty\n'
              '• intl - Internacionalizace\n\n'
              'Děkujeme všem přispěvatelům těchto projektů!',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Zavřít'),
            ),
          ],
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
