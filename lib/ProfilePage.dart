import 'package:flutter/material.dart';
import 'models/login.dart';
import 'SettingsPage.dart';

class ProfilePage extends StatelessWidget {
  final Login login;

  const ProfilePage({super.key, required this.login});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Card(child: Icon(Icons.person, size: 100))),
            SizedBox(height: 20),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text('Jméno'),
                    subtitle: Text(login.fullName),
                  ),
                  ListTile(
                    title: Text('Email'),
                    subtitle: Text(login.userName),
                  ),
                  ListTile(
                    title: Text('Kredit'),
                    subtitle: Text('${login.credit} Kč'),
                  ),
                  ListTile(
                    title: Text('Stravovací zařízení'),
                    subtitle: Text(login.facilityName),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed("/", arguments: false);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Odhlásit se'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
