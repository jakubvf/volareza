import 'package:flutter/material.dart';

import 'models/login.dart';
import 'OrderPage.dart';
import 'ProfilePage.dart';
import 'VolarezaService.dart';
import 'timetable.dart';

class MainScreen extends StatefulWidget {
  final Login login;
  final VolarezaService volarezaService;

  const MainScreen({super.key, required this.login, required this.volarezaService});

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
      // TODO: A homepage
      OrderPage(login: widget.login, volarezaService: widget.volarezaService),
      TimetablePage(),
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
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu),
              label: 'Objednávky',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month),
                label: 'Rozvrh'
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