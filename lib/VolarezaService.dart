import 'package:flutter/cupertino.dart';

import './models/facility.dart';
import './models/login.dart';
import './ApiClient.dart';

class VolarezaService {
  final ApiClient _apiClient;

  Facility? _facility;
  Login? _login;

  DateTime _loginTime = DateTime.fromMillisecondsSinceEpoch(0);
  final ValueNotifier<bool> needsRelogin = ValueNotifier<bool>(false);

  VolarezaService(this._apiClient);

  Future<Login> login(String username, String password) async {
    _loginTime = DateTime.now();
    _login = await _apiClient.login(username, password);
    return _login!;
  }

  Future<Facility> getFacility() async {
    checkLogin();

    _facility ??= await _apiClient.getFacility();
    return _facility!;
  }

  void checkLogin() {
    if (_loginTime.isBefore(DateTime.now().subtract(const Duration(minutes: 15)))) {
      needsRelogin.value = true;
      _facility = null;
    } else {
      needsRelogin.value = false;
    }
  }
}