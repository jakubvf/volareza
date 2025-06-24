import 'package:flutter/material.dart';

import 'settings_notifier.dart';

class SettingsProvider extends StatefulWidget {
  final Widget child;

  const SettingsProvider({
    super.key,
    required this.child,
  });

  static SettingsNotifier of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<_SettingsInheritedWidget>();
    if (provider == null) {
      throw FlutterError(
        'SettingsProvider.of() called with a context that does not contain a SettingsProvider.\n'
        'Make sure that SettingsProvider is an ancestor of the widget calling SettingsProvider.of().',
      );
    }
    return provider.settings;
  }

  static SettingsNotifier? maybeOf(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<_SettingsInheritedWidget>();
    return provider?.settings;
  }

  @override
  State<SettingsProvider> createState() => _SettingsProviderState();
}

class _SettingsProviderState extends State<SettingsProvider> {
  SettingsNotifier? _settings;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    try {
      final settings = await SettingsNotifier.create();
      if (mounted) {
        setState(() {
          _settings = settings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Načítám nastavení...',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Chyba při načítání nastavení',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _error = null;
                    });
                    _initializeSettings();
                  },
                  child: const Text('Zkusit znovu'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListenableBuilder(
      listenable: _settings!,
      builder: (context, child) {
        return _SettingsInheritedWidget(
          settings: _settings!,
          child: widget.child,
        );
      },
    );
  }

  @override
  void dispose() {
    _settings?.dispose();
    super.dispose();
  }
}

class _SettingsInheritedWidget extends InheritedWidget {
  final SettingsNotifier settings;

  const _SettingsInheritedWidget({
    required this.settings,
    required super.child,
  });

  @override
  bool updateShouldNotify(_SettingsInheritedWidget oldWidget) {
    return true;
  }
}