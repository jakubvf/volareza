import 'package:flutter/material.dart';
import 'json_parsing.dart';

class ProfilePage extends StatelessWidget {
  final Login login;

  const ProfilePage({super.key, required this.login});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
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
                    title: Text('Name'),
                    subtitle: Text(login.fullName),
                  ),
                  ListTile(
                    title: Text('Email'),
                    subtitle: Text(login.userNm),
                  ),
                  ListTile(
                    title: Text('Credit'),
                    subtitle: Text('${login.credit} Kč'),
                  ),
                  ListTile(
                    title: Text('Facility'),
                    subtitle: Text(login.facNm),
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
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
