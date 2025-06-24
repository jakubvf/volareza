import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _themeMode = ThemeMode.system;
    _colorSeed = Colors.deepPurple;
    _defaultEatery = null;
    _showWeekends = false;
  }

  static Future<SettingsNotifier> create() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifier = SettingsNotifier._(prefs);
      await notifier._loadPreferences();
      return notifier;
    } catch (e) {
      throw Exception('Failed to initialize settings: $e');
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final themeModeString = _prefs.getString(_themeModeKey);
      if (themeModeString != null) {
        _themeMode = _parseThemeMode(themeModeString);
      }

      final colorValue = _prefs.getInt(_colorSeedKey);
      if (colorValue != null && _isValidColorValue(colorValue)) {
        _colorSeed = Color(colorValue);
      }

      final defaultEatery = _prefs.getString(_defaultEateryKey);
      if (defaultEatery != null && defaultEatery.isNotEmpty) {
        _defaultEatery = defaultEatery;
      }

      final showWeekends = _prefs.getBool(_showWeekendsKey);
      if (showWeekends != null) {
        _showWeekends = showWeekends;
      }
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  ThemeMode _parseThemeMode(String value) {
    try {
      return ThemeMode.values.firstWhere(
        (mode) => mode.toString() == value,
        orElse: () => ThemeMode.system,
      );
    } catch (e) {
      debugPrint('Invalid theme mode value: $value');
      return ThemeMode.system;
    }
  }

  bool _isValidColorValue(int value) {
    return value >= 0 && value <= 0xFFFFFFFF;
  }

  ThemeMode get themeMode => _themeMode;
  Color get colorSeed => _colorSeed;
  String? get defaultEatery => _defaultEatery;
  bool get showWeekends => _showWeekends;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    try {
      _themeMode = mode;
      await _prefs.setString(_themeModeKey, mode.toString());
      notifyListeners();
    } catch (e) {
      _themeMode = ThemeMode.system;
      debugPrint('Failed to save theme mode: $e');
      rethrow;
    }
  }

  Future<void> setColorSeed(Color color) async {
    if (_colorSeed == color) return;
    
    try {
      _colorSeed = color;
      await _prefs.setInt(_colorSeedKey, color.toARGB32());
      notifyListeners();
    } catch (e) {
      _colorSeed = Colors.deepPurple;
      debugPrint('Failed to save color seed: $e');
      rethrow;
    }
  }

  Future<void> setDefaultEatery(String eatery) async {
    if (_defaultEatery == eatery) return;
    
    try {
      _defaultEatery = eatery;
      await _prefs.setString(_defaultEateryKey, eatery);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to save default eatery: $e');
      rethrow;
    }
  }

  Future<void> setShowWeekends(bool showWeekends) async {
    if (_showWeekends == showWeekends) return;
    
    try {
      _showWeekends = showWeekends;
      await _prefs.setBool(_showWeekendsKey, showWeekends);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to save show weekends setting: $e');
      rethrow;
    }
  }

  Future<void> resetToDefaults() async {
    try {
      await _prefs.remove(_themeModeKey);
      await _prefs.remove(_colorSeedKey);
      await _prefs.remove(_defaultEateryKey);
      await _prefs.remove(_showWeekendsKey);
      
      _themeMode = ThemeMode.system;
      _colorSeed = Colors.deepPurple;
      _defaultEatery = null;
      _showWeekends = false;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to reset settings: $e');
      rethrow;
    }
  }
}