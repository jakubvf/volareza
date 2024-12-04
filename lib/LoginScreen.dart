import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:volareza/MainScreen.dart';
import 'package:volareza/main.dart';
import 'ApiClient.dart';
import 'Facility.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key, this.autoLogin = true, required this.themeNotifier});
  final bool autoLogin;
  final ThemeNotifier themeNotifier;

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: "");
  final _passwordController = TextEditingController(text: "");
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final apiClient = ApiClient(_emailController.text, _passwordController.text);

      apiClient.login((error, response) async {
        setState(() {
          _isLoading = false;
        });

        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: ${error.toString()}')));
        } else {

          if (!kDebugMode) {
            // Save email and password to secure storage
            await _storage.write(key: 'email', value: _emailController.text);
            await _storage.write(
                key: 'password', value: _passwordController.text);
          }

          Login login = Login.fromJson(jsonDecode(response!)['data']);

          // Navigate to another screen or perform other actions
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen(apiClient: apiClient, login: login, themeNotifier: widget.themeNotifier,)),
            );
          }
        }
      });
    }
  }

  @override @override
  void initState() {
    super.initState();
    if (widget.autoLogin && !kDebugMode) _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    final email = await _storage.read(key: 'email');
    final password = await _storage.read(key: 'password');

    if (email != null && password != null) {
      _emailController.text = email;
      _passwordController.text = password;
      _submit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                autofocus: true,
                onPressed: _submit,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}