import 'package:flutter/material.dart';

import 'LoginScreen.dart';
import 'settings/settings_provider.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsProvider(
      child: const _MaterialAppWithSettings(),
    );
  }
}

class _MaterialAppWithSettings extends StatelessWidget {
  const _MaterialAppWithSettings();

  @override
  Widget build(BuildContext context) {
    final settings = SettingsProvider.of(context);
    return MaterialApp(
      title: 'Volareza',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: settings.colorSeed,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: settings.colorSeed,
      ),
      themeMode: settings.themeMode,
      home: const LoginScreen(),
    );
  }
}


