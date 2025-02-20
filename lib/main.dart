import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LoginScreen.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize theme notifier with saved preferences
  final themeNotifier = await SettingsNotifier.create();

  runApp(MyApp(themeNotifier: themeNotifier));
}

class MyApp extends StatelessWidget {
  final SettingsNotifier themeNotifier;

  const MyApp({
    super.key,
    required this.themeNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeNotifier,
      builder: (context, child) {
        return MaterialApp(
          title: 'Volareza',
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorSchemeSeed: themeNotifier.colorSeed,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: themeNotifier.colorSeed,
          ),
          themeMode: themeNotifier.themeMode,
          home: LoginScreen(themeNotifier: themeNotifier),
        );
      },
    );
  }
}

class SettingsNotifier extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _colorSeedKey = 'color_seed';
  static const String _defaultEateryKey = 'default_eatery';

  late ThemeMode _themeMode;
  late Color _colorSeed;
  late String? _defaultEatery;

  final SharedPreferences _prefs;

  SettingsNotifier._(this._prefs) {
    // Initialize with default values
    _themeMode = ThemeMode.system;
    _colorSeed = Colors.deepPurple;
    _defaultEatery = null;
  }

  static Future<SettingsNotifier> create() async {
    final prefs = await SharedPreferences.getInstance();
    final notifier = SettingsNotifier._(prefs);
    await notifier._loadPreferences();
    return notifier;
  }

  Future<void> _loadPreferences() async {
    // Load theme mode
    final themeModeString = _prefs.getString(_themeModeKey);
    if (themeModeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
            (e) => e.toString() == themeModeString,
        orElse: () => ThemeMode.system,
      );
    }

    // Load color seed
    final colorValue = _prefs.getInt(_colorSeedKey);
    if (colorValue != null) {
      _colorSeed = Color(colorValue);
    }

    final defaultEatery = _prefs.getString('default_eatery');
    if (defaultEatery != null) {
      _defaultEatery = defaultEatery;
    }
  }

  ThemeMode get themeMode => _themeMode;
  Color get colorSeed => _colorSeed;
  String? get defaultEatery => _defaultEatery;

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(_themeModeKey, mode.toString());
    notifyListeners();
  }

  Future<void> setColorSeed(Color color) async {
    _colorSeed = color;
    // TODO: using toARGB32 causes the UI to show unknown color after restart
    await _prefs.setInt(_colorSeedKey, color.toARGB32());
    notifyListeners();
  }

  Future<void> setDefaultEatery(String eatery) async {
    _defaultEatery = eatery;
    await _prefs.setString(_defaultEateryKey, eatery);
    notifyListeners();
  }
}

