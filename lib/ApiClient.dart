import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:volareza/models/menu.dart';
import 'package:volareza/error_handler.dart';

import 'models/facility.dart';
import 'models/login.dart';

class ApiClient {
  static final ApiClient instance = ApiClient._internal();
  ApiClient._internal();
  
  final String baseUrl = 'https://unob.jidelny-vlrz.cz';
  String? phpSessionIdCookie = '';
  DateTime? _lastLoginTime;
  bool _isReauthenticating = false;
  
  // Stored credentials for singleton pattern
  static String? _username;
  static String? _password;
  
  // Session timeout - 15 minutes as per API documentation
  static const Duration sessionTimeout = Duration(minutes: 15);
  
  static void initialize(String username, String password) {
    _username = username;
    _password = password;
  }
  
  bool get isSessionExpired {
    if (_lastLoginTime == null) return true;
    return DateTime.now().difference(_lastLoginTime!) > sessionTimeout;
  }
  
  void _updateLoginTime() {
    _lastLoginTime = DateTime.now();
  }

  static String hashPassword(String input) {
    List<int> bytes = utf8.encode(input);
    Digest digest = md5.convert(bytes);
    return digest.toString();
  }

  // Generic Request Method with automatic re-authentication
  Future<dynamic> _makeRequest({
    required String path,
    required String req,
    Map<String, dynamic>? data,
    String method = 'POST',
    bool isRetry = false,
  }) async {
    // Check if session is expired and we need to re-authenticate
    if (!isRetry && req != 'login' && (isSessionExpired || _shouldReauthenticate())) {
      try {
        await _reauthenticate();
      } catch (e) {
        throw AppError(
          type: ErrorType.authentication,
          message: 'Re-authentication failed',
          userMessage: 'Nepodařilo se obnovit přihlášení. Přihlaste se znovu.',
          canRetry: false,
        );
      }
    }
    
    final uri = Uri.parse('$baseUrl$path?req=$req');
    final reqData = jsonEncode(data);

    try {
      final client = http.Client();

      final request = http.Request(method, uri);
      request.headers['Content-Type'] = 'application/json';

      if (phpSessionIdCookie != null && phpSessionIdCookie!.isNotEmpty) {
        request.headers['Cookie'] = phpSessionIdCookie!;
      }

      request.body = reqData;
      final streamedResponse = await client.send(request).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timeout', const Duration(seconds: 30));
        },
      );
      final response = await http.Response.fromStream(streamedResponse);

      // Update cookie from response
      final setCookieHeader = response.headers['set-cookie'];
      if (setCookieHeader != null) {
        phpSessionIdCookie = setCookieHeader.split(';')[0];
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
          
          // Check if response indicates an error (API always returns 200)
          if (decodedBody is Map<String, dynamic> && decodedBody.containsKey('severity')) {
            final appError = ErrorHandler.handleApiResponse(decodedBody, context: req);
            
            // If it's a session expiry error and this isn't a retry, try to re-authenticate
            if (!isRetry && appError.type == ErrorType.sessionExpired && req != 'login') {
              try {
                await _reauthenticate();
                // Retry the original request
                return await _makeRequest(
                  path: path,
                  req: req,
                  data: data,
                  method: method,
                  isRetry: true,
                );
              } catch (e) {
                // Re-authentication failed, rethrow the original error
                rethrow;
              }
            }
            
            throw appError;
          }
          
          return decodedBody;
        } catch (e) {
          if (e is AppError) {
            throw e;
          }
          throw ErrorHandler.handleException(
            FormatException('Failed to parse JSON: ${e.toString()}'),
            context: req,
          );
        }
      } else {
        throw ErrorHandler.handleException(
          HttpException('HTTP ${response.statusCode}'),
          context: req,
        );
      }
    } catch (e) {
      if (e is AppError) {
        throw e;
      }
      if (e is TimeoutException) {
        throw ErrorHandler.handleException(e, context: req);
      }
      if (e is SocketException) {
        throw ErrorHandler.handleException(e, context: req);
      }
      throw ErrorHandler.handleException(
        Exception('Request failed: ${e.toString()}'),
        context: req,
      );
    }
  }
  
  bool _shouldReauthenticate() {
    // Check if we have no cookie or it's empty
    return phpSessionIdCookie == null || phpSessionIdCookie!.isEmpty;
  }
  
  Future<void> _reauthenticate() async {
    if (_isReauthenticating) {
      // Wait for existing re-authentication to complete
      while (_isReauthenticating) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return;
    }
    
    if (_username == null || _password == null) {
      throw AppError(
        type: ErrorType.authentication,
        message: 'No stored credentials for re-authentication',
        userMessage: 'Přihlašovací údaje nejsou k dispozici. Přihlaste se znovu.',
        canRetry: false,
      );
    }
    
    _isReauthenticating = true;
    try {
      // Clear existing cookie
      phpSessionIdCookie = '';
      
      // Perform login using stored credentials
      await _loginInternal(_username!, _password!);
      _updateLoginTime();
    } finally {
      _isReauthenticating = false;
    }
  }

  // API Methods

  Future<Login> login(String username, String password) async {
    final result = await _loginInternal(username, password);
    _updateLoginTime();
    return result;
  }
  
  Future<Login> _loginInternal(String username, String password) async {
    final data = {
      'facId': '10',
      'userNm': username,
      'userPwd': hashPassword(password),
      'lang': 'CZ',
      'remLogin': false
    };
    final response = await _makeRequest(path: '/service/', req: 'login', data: data);
    return Login.fromJson(response['data']);
  }

  // Singleton login method using stored credentials
  Future<Login> loginWithStoredCredentials() async {
    if (_username == null || _password == null) {
      throw ApiException('ApiClient not initialized. Call initialize() first.');
    }
    return login(_username!, _password!);
  }

  Future<Facility> getFacility() async {
    final response = await _makeRequest(path: '/service/', req: 'facility');
    return Facility.fromJson(response['data']);
  }

  Future<Menu> getMenuForDate(String preferredEatery, String date) async {
    final data = {
      'eatery': preferredEatery,
      'date': date,
    };
    final response = await _makeRequest(path: '/service/', req: 'facility', data: data);
    return Menu.fromJson(response['data'], date);
  }

  // Alias for OrderPage compatibility
  Future<Menu> getDay(String preferredEatery, String date) async {
    return getMenuForDate(preferredEatery, date);
  }

  /// Unused, here for reference
  Future<void> selectMeal(String date, String eatery, String mealType, String mealId, String menuId) async {
    final data = {
      'mealSel': [
        {
          'mealSel': true,
          'date': date,
          'eatery': eatery,
          'mealTp': mealType,
          'mealId': mealId,
          'menuId': menuId
        }
      ]
    };
    await _makeRequest(path: '/service/', req: 'mealSel', data: data);
  }

  Future<void> order(String date, String eatery, String mealId, String menuId) async {
    final data = {
      'date': date,
      'eatery': eatery,
      'mealTp': "O", // we only support ordering for lunch
      'meals': [
        {
          'mealId': mealId,
          'menuId': menuId,
          'group': 0 // What is this?
        }
      ]
    };
    await _makeRequest(path: '/service/', req: 'order', data: data);
  }

  Future<bool> cancelOrder(String date, String eatery) async {
    final data = {
      'date': date,
      'eatery': eatery,
      'mealTp': "O", // we only support ordering for lunch
    };
    final result = await _makeRequest(path: '/service/', req: 'cancelOrder', data: data);

    // This is my way of figuring out if the result was an error. I know not ideal.
    return !result.containsKey('severity');
  }

  Future<void> exchange(String date, String eatery, bool exchange, {mealType = "O"}) async {
    final data = {
      'exchange': exchange,
      'date': date,
      'eatery': eatery,
      'mealTp': mealType,
    };
    await _makeRequest(path: '/service/', req: 'exchange', data: data);
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() {
    return 'ApiException: $message (Status Code: $statusCode)';
  }
}
