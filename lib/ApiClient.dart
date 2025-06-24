import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:volareza/models/menu.dart';

import 'models/facility.dart';
import 'models/login.dart';

class ApiClient {
  static final ApiClient instance = ApiClient._internal();
  ApiClient._internal();
  
  final String baseUrl = 'https://unob.jidelny-vlrz.cz';
  String? phpSessionIdCookie = '';
  
  // Stored credentials for singleton pattern
  static String? _username;
  static String? _password;
  
  static void initialize(String username, String password) {
    _username = username;
    _password = password;
  }

  static String hashPassword(String input) {
    List<int> bytes = utf8.encode(input);
    Digest digest = md5.convert(bytes);
    return digest.toString();
  }

  // Generic Request Method
  Future<dynamic> _makeRequest({
    required String path,
    required String req,
    Map<String, dynamic>? data,
    String method = 'POST',
  }) async {
    final uri = Uri.parse('$baseUrl$path?req=$req');
    final reqData = jsonEncode(data);

    try {
      final client = http.Client();

      final request = http.Request(method, uri);
      request.headers['Content-Type'] = 'application/json';

      if (phpSessionIdCookie != null) {
        request.headers['Cookie'] = phpSessionIdCookie!;
      }

      request.body = reqData;
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      // We basically want to save the PHPSESSIONID cookie and ignore the rest
      final setCookieHeader = response.headers['set-cookie'];
      if (setCookieHeader != null) {
          phpSessionIdCookie = setCookieHeader.split(';')[0];
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
          return decodedBody;
        } catch (e) {
          throw ApiException('Failed to parse JSON: ${e.toString()}');
        }
      } else {
        throw ApiException(
            'Request failed', statusCode: response.statusCode);
      }
    } catch (e) {
      throw ApiException('Request failed: ${e.toString()}');
    }
  }

  // API Methods

  Future<Login> login(String username, String password) async {
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
