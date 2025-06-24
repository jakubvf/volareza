import 'package:flutter/material.dart';

import 'models/login.dart';
import 'OrderPage.dart';
import 'ProfilePage.dart';
import 'SettingsPage.dart';
import 'VolarezaService.dart';
import 'main.dart';

class MainScreen extends StatefulWidget {
  final Login login;
  final SettingsNotifier settingsNotifier;
  final VolarezaService volarezaService;

  MainScreen({super.key, required this.login, required this.settingsNotifier, required this.volarezaService});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedPageIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      OrderPage(login: widget.login, settingsNotifier: widget.settingsNotifier, volarezaService: widget.volarezaService),
      SettingsPage(settingsNotifier: widget.settingsNotifier),
      ProfilePage(login: widget.login),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _pages.elementAt(_selectedPageIndex),
        ),
        BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu),
              label: 'Objednávky',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Nastavení',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
          currentIndex: _selectedPageIndex,
          onTap: _onItemTapped,
        ),
      ],
    );
  }
}