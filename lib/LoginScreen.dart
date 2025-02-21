import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:volareza/MainScreen.dart';
import 'package:volareza/main.dart';
import 'ApiClient.dart';

/// Handles user login. If the login is successful, the user is redirected to the [MainScreen].
///
/// If there are credentials in the secure storage, the user is automatically logged in.
///
/// The user can log out from the settings screen. See `autoLogin`.
class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key, this.autoLogin = true, required this.settingsNotifier});
  /// `autoLogin` prevents loading credentials from secure storage.
  ///
  /// Used for logging out from the settings screen.
  final bool autoLogin;
  final SettingsNotifier settingsNotifier;

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: "");
  final _passwordController = TextEditingController(text: "");
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!mounted) return;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // initialize ApiClient - a singleton handling all API requests
      ApiClient.initialize(_emailController.text, _passwordController.text);

      try {
        final loginResult = await ApiClient.instance.login(); // Call the async login method

        setState(() {
          _isLoading = false;
        });

        // Secure storage doesn't work for me when running on desktop
        if (!kDebugMode) {
          // Save email and password to secure storage
          await _storage.write(key: 'email', value: _emailController.text);
          await _storage.write(
              key: 'password', value: _passwordController.text);
        }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen(login: loginResult, settingsNotifier: widget.settingsNotifier,)),
          );


      } on ApiException catch (e) {
        // Handle API-specific errors
        setState(() {
          _isLoading = false;
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Přihlášení se nezdařilo: ${e.message}')));
        }
      } catch (e) {
        // Handle other unexpected errors
        setState(() {
          _isLoading = false;
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Přihlášení se nezdařilo: ${e.toString()}')));
        }
      }
    }
  }

  @override @override
  void initState() {
    super.initState();
    // tries to load credentials from storage
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
                    return 'Doplňte email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Heslo'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Doplňte heslo';
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
                child: Text('Přihlásit se'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}