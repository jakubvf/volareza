import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:volareza/MainScreen.dart';
import 'ApiClient.dart';
import 'VolarezaService.dart';
import 'error_handler.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:url_launcher/url_launcher_string.dart';

/// Handles user login. If the login is successful, the user is redirected to the [MainScreen].
///
/// If there are credentials in the secure storage, the user is automatically logged in.
///
/// The user can log out from the settings screen. See `autoLogin`.
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.autoLogin = true,
  });

  /// `autoLogin` prevents loading credentials from secure storage.
  ///
  /// Used for logging out from the settings screen.
  final bool autoLogin;

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
        final loginResult =
        await ApiClient.instance.loginWithStoredCredentials(); // Call the async login method

        // Create VolarezaService instance
        final volarezaService = VolarezaService(ApiClient.instance);

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
          MaterialPageRoute(
              builder: (context) => MainScreen(
                login: loginResult,
                volarezaService: volarezaService,
              )),
        );
      } on AppError catch (e) {
        // Handle AppError with user-friendly messages
        setState(() {
          _isLoading = false;
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.userMessage),
            duration: const Duration(seconds: 4),
          ));
        }
      } on ApiException catch (e) {
        // Handle legacy ApiException
        setState(() {
          _isLoading = false;
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Přihlášení se nezdařilo: ${e.message}')));
        }
      } catch (e) {
        // Handle other unexpected errors
        final appError = ErrorHandler.handleException(
          e is Exception ? e : Exception(e.toString()),
        );
        setState(() {
          _isLoading = false;
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(appError.userMessage)));
        }
      }
    }
  }

  @override
  @override
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
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Přihlášení'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              isDarkTheme ? 'assets/volareza-dark.png' : 'assets/volareza.png',
              height: 100,
            ),
            Spacer(),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: [AutofillHints.email],
                        textInputAction: TextInputAction.next,
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
                        enableSuggestions: false,
                        autofillHints: [AutofillHints.password],
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
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'Nemáte účet?',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  InkWell(
                    child: Text(
                      'Registrovat se můžete zde',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    onTap: () async {
                      final Uri url =
                      Uri.parse('https://jidelny-vlrz.cz/login/');
                      // if (!await launchUrl(url)) {
                      //   throw Exception('Could not launch $url');
                      // }
                    },
                  ),
                ],
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
