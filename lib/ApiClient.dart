import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import 'json_parsing.dart';

class ApiClient {
  final String username;
  final String password;
  final String baseUrl = 'https://unob.jidelny-vlrz.cz';
  String? phpSessionIdCookie = '';

  ApiClient._internal(this.username, this.password);

  static late ApiClient instance;

  static Future<void> initialize(String username, String password) async {
    instance = ApiClient._internal(username, password);
  }

  static String hashPassword(String input) {
    List<int> bytes = utf8.encode(input);
    Digest digest = md5.convert(bytes);
    return digest.toString();
  }

  // Generic Request Method (Internal)
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

  Future<Login> login() async {
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

  Future<Facility> getFacility() async {
    final response = await _makeRequest(path: '/service/', req: 'facility');
    return Facility.fromJson(response['data']);
  }

  Future<Day> getDay(String preferredEatery, String date) async {
    final data = {
      'eatery': preferredEatery,
      'date': date,
    };
    final response = await _makeRequest(path: '/service/', req: 'facility', data: data);
    return Day.fromJson(response['data'], date);
  }

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

  Future<void> cancelOrder(String date, String eatery) async {
    final data = {
      'date': date,
      'eatery': eatery,
      'mealTp': "O", // we only support ordering for lunch
    };
    await _makeRequest(path: '/service/', req: 'cancelOrder', data: data);
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
