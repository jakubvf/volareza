import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LoginScreen.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize theme notifier with saved preferences
  final settingsNotifier = await SettingsNotifier.create();

  runApp(MyApp(settingsNotifier: settingsNotifier));
}

class MyApp extends StatelessWidget {
  final SettingsNotifier settingsNotifier;

  const MyApp({
    super.key,
    required this.settingsNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsNotifier,
      builder: (context, child) {
        return MaterialApp(
          title: 'Volareza',
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorSchemeSeed: settingsNotifier.colorSeed,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: settingsNotifier.colorSeed,
          ),
          themeMode: settingsNotifier.themeMode,
          home: LoginScreen(settingsNotifier: settingsNotifier),
        );
      },
    );
  }
}

class SettingsNotifier extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _colorSeedKey = 'color_seed';
  static const String _defaultEateryKey = 'default_eatery';
  static const String _showWeekendsKey = 'show_weekends';

  late ThemeMode _themeMode;
  late Color _colorSeed;
  late String? _defaultEatery;
  late bool _showWeekends;

  final SharedPreferences _prefs;

  SettingsNotifier._(this._prefs) {
    // Initialize with default values
    _themeMode = ThemeMode.system;
    _colorSeed = Colors.deepPurple;
    _defaultEatery = null;
    _showWeekends = false;
  }

  static Future<SettingsNotifier> create() async {
    final prefs = await SharedPreferences.getInstance();
    final notifier = SettingsNotifier._(prefs);
    await notifier._loadPreferences();
    return notifier;
  }

  Future<void> _loadPreferences() async {
    final themeModeString = _prefs.getString(_themeModeKey);
    if (themeModeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
            (e) => e.toString() == themeModeString,
        orElse: () => ThemeMode.system,
      );
    }

    final colorValue = _prefs.getInt(_colorSeedKey);
    if (colorValue != null) {
      _colorSeed = Color(colorValue);
    }

    final defaultEatery = _prefs.getString('default_eatery');
    if (defaultEatery != null) {
      _defaultEatery = defaultEatery;
    }

    final showWeekends = _prefs.getBool(_showWeekendsKey);
    if (showWeekends != null) {
      _showWeekends = showWeekends;
    }
  }

  ThemeMode get themeMode => _themeMode;
  Color get colorSeed => _colorSeed;
  String? get defaultEatery => _defaultEatery;
  bool get showWeekends => _showWeekends;

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(_themeModeKey, mode.toString());
    notifyListeners();
  }

  Future<void> setColorSeed(Color color) async {
    _colorSeed = color;
    await _prefs.setInt(_colorSeedKey, color.toARGB32());
    notifyListeners();
  }

  Future<void> setDefaultEatery(String eatery) async {
    _defaultEatery = eatery;
    await _prefs.setString(_defaultEateryKey, eatery);
    notifyListeners();
  }

  Future<void> setShowWeekends(bool showWeekends) async {
    _showWeekends = showWeekends;
    await _prefs.setBool(_showWeekendsKey, showWeekends);
    notifyListeners();
  }
}

