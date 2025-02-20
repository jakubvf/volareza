import 'package:flutter/material.dart';

import 'ApiClient.dart';
import 'Facility.dart';
import 'OrderPage.dart';
import 'ProfilePage.dart';
import 'SettingsPage.dart';
import 'main.dart';

class MainScreen extends StatefulWidget {
  final ApiClient apiClient = ApiClient();
  final Login login;
  final SettingsNotifier themeNotifier;

  MainScreen({super.key, required this.login, required this.themeNotifier});

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
      OrderPage(login: widget.login),
      SettingsPage(themeNotifier: widget.themeNotifier,),
      ProfilePage(login: widget.login,),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(_selectedPageIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedPageIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
