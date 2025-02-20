import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

typedef Callback = void Function(Exception? error, String? response);

class ApiClient {
  final String username;
  final String password;
  String _cookies = '';

  ApiClient._internal(this.username, this.password);

  static ApiClient? _instance;

  static void initialize(String username, String password) {
    _instance = ApiClient._internal(username, password);
  }

  factory ApiClient() {
    return _instance!;
  }

  static String hashPassword(String input) {
    List<int> bytes = utf8.encode(input);
    Digest digest = md5.convert(bytes);
    return digest.toString();
  }

  Future<void> makeRequest(
      String path, Map<String, dynamic> data, Callback callback) async {
    final reqData = jsonEncode(data);

    try {
      final response = await http.post(
        Uri.parse('https://unob.jidelny-vlrz.cz$path'),
        headers: {
          'Content-Type': 'application/json',
          if (_cookies.isNotEmpty) 'Cookie': _cookies,
        },
        body: reqData,
      );

      if (response.statusCode == 200 && !response.body.contains('error')) {
        final setCookieHeader = response.headers['set-cookie'];
        if (setCookieHeader != null) {
          _cookies = setCookieHeader.split(';')[0];
        }
        callback(null, utf8.decode(response.bodyBytes));
      } else {
        callback(Exception('Request failed with status ${response.statusCode}'),
            null);
      }
    } catch (error) {
      callback(Exception(error.toString()), null);
    }
  }

  void login(Callback callback) {
    final data = {
      'req': 'login',
      'facId': '10',
      'userNm': username,
      'userPwd': hashPassword(password),
      'lang': 'CZ',
      'remLogin': false
    };

    makeRequest('/service/?req=login', data, callback);
  }

  void getFacility(Callback callback) {
    final data = {
      'req': 'facility',
    };

    makeRequest('/service/?req=facility', data, callback);
  }

  void getDay(String preferredEatery, String date, Callback callback) {
    final data = {
      'req': 'facility',
      'eatery': preferredEatery,
      'date': date,
    };

    makeRequest('/service/?req=facility', data, callback);
  }

  void selectMeal(String date, String eatery, String mealType, String mealId, String menuId, Callback callback) {
    final data = {
      'req': 'mealSel',
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

    makeRequest('/service/?req=mealSel', data, callback);
  }

  void order(String date, String eatery, String mealId, String menuId, Callback callback) {
    final data = {
      'req': 'order',
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

    makeRequest('/service/?req=order', data, callback);
  }

  void cancelOrder(String date, String eatery, Callback callback) {
    final data = {
      'req': 'cancelOrder',
      'date': date,
      'eatery': eatery,
      'mealTp': "O", // we only support ordering for lunch
    };

    makeRequest('/service/?req=cancelOrder', data, callback);
  }
}
