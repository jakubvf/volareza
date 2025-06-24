import 'package:flutter/cupertino.dart';

import './models/facility.dart';
import './models/login.dart';
import './models/menu.dart';
import './ApiClient.dart';

class VolarezaService {
  final ApiClient _apiClient;

  Facility? _facility;
  Login? _login;
  final Map<String, Menu> _cachedDays = {};

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

  Future<Menu> getDay(String eateryId, String date) async {
    checkLogin();

    final cacheKey = '${eateryId}_$date';
    if (_cachedDays.containsKey(cacheKey)) {
      return _cachedDays[cacheKey]!;
    }

    final day = await _apiClient.getDay(eateryId, date);
    _cachedDays[cacheKey] = day;
    return day;
  }

  Future<void> order(String date, String eatery, String mealId, String menuId) async {
    checkLogin();
    await _apiClient.order(date, eatery, mealId, menuId);
    _invalidateCache(eatery, date);
  }

  Future<bool> cancelOrder(String date, String eatery) async {
    checkLogin();
    final result = await _apiClient.cancelOrder(date, eatery);
    _invalidateCache(eatery, date);
    return result;
  }

  Future<void> exchange(String date, String eatery, bool exchange) async {
    checkLogin();
    await _apiClient.exchange(date, eatery, exchange);
    _invalidateCache(eatery, date);
  }

  void _invalidateCache(String eatery, String date) {
    final cacheKey = '${eatery}_$date';
    _cachedDays.remove(cacheKey);
  }

  void clearCache() {
    _cachedDays.clear();
  }

  void checkLogin() {
    if (_loginTime.isBefore(DateTime.now().subtract(const Duration(minutes: 15)))) {
      needsRelogin.value = true;
      _facility = null;
      clearCache();
    } else {
      needsRelogin.value = false;
    }
  }
}