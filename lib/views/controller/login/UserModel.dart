import 'package:flutter/material.dart';

class User {
  final String username;
  final String password;

  User({required this.username, required this.password});
}

class LoginViewModel extends ChangeNotifier {
  String _username = '';
  String _password = '';
  bool _mantenerSesion = false;
  bool _isLoading = false;

  String get username => _username;
  String get password => _password;
  bool get mantenerSesion => _mantenerSesion;
  bool get isLoading => _isLoading;

  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  void toggleMantenerSesion() {
    _mantenerSesion = !_mantenerSesion;
    notifyListeners();
  }

  Future<bool> login() async {
    _isLoading = true;
    notifyListeners();

    // Simular login con retardo
    await Future.delayed(Duration(seconds: 2));

    _isLoading = false;
    notifyListeners();


    print('Username: $_username, Password: $_password');

    return _username == 'test' && _password == '1234';
  }
}

