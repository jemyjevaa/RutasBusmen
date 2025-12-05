import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'ResponseServ.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();
  SharedPreferences? _prefs;

  factory UserSession() {
    return _instance;
  }

  UserSession._internal();

  // Inicializar SharedPreferences una sola vez (ejecutar al iniciar la app)
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  bool get isLogin => _prefs?.getBool('isLogin') ?? false;
  set isLogin(bool value) => _prefs?.setBool('isLogin', value);

  // region persist data user

  bool get isPersist => _prefs?.getBool('isPersist') ?? false;
  set isPersist(bool value) => _prefs?.setBool('isPersist', value);

  String? get email => _prefs?.getString('email');
  set email(String? value) => _prefs?.setString('email', value ?? '');

  String? get token => _prefs?.getString('token');
  set token(String? value) => _prefs?.setString('token', value ?? '');

  // endregion persist data user

  // region Login Data

  Future<void> setUserData(Map<String, dynamic> userData) async {
    String jsonString = jsonEncode(userData);
    await _prefs?.setString('userData', jsonString);
  }

  Usuario? getUserData() {
    final jsonString = _prefs?.getString('userData');
    if (jsonString == null || jsonString.isEmpty) return null;

    final Map<String, dynamic> map = jsonDecode(jsonString);
    return Usuario.fromJson(map);
  }

  Future<void> setCompanyData(Map<String, dynamic> companyData)async{
    String jsonString = jsonEncode(companyData);
    await _prefs?.setString('companyData', jsonString);
  }

  Empresa? getCompanyData() {
    final jsonString = _prefs?.getString('companyData');
    if (jsonString == null || jsonString.isEmpty) return null;

    final Map<String, dynamic> map = jsonDecode(jsonString);
    return Empresa.fromJson(map);
  }


  // endregion Login Data

  // Limpiar datos
  Future<void> clear() async {
    _prefs?.remove("userData");
    _prefs?.remove("companyData");
    isLogin = false;
    // setUserData(null);
  }
}
