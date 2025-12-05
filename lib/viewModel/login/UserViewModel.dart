import 'package:flutter/material.dart';

import '../../../services/RequestServ.dart';
import '../../../services/ResponseServ.dart';
import '../../../services/UserSession.dart';

class User {
  final String username;
  final String password;

  User({required this.username, required this.password});
}

class LoginViewModel extends ChangeNotifier {
  final session = UserSession();

  String _username = '';
  String _password = '';
  late bool _mantenerSesion = session.isPersist;
  bool _isLoading = false;



  String get username => _username;
  String get password => _password;
  bool get mantenerSesion => _mantenerSesion;
  bool get isLoading => _isLoading;

  void setUsername(String username) {
    _username = username;
    if(session.isPersist){
      session.email = _username;
    }
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    if(session.isPersist){
      session.token = _password;
    }
    notifyListeners();
  }

  void togglePersistSession() {
    _mantenerSesion = !_mantenerSesion;
    session.isPersist = _mantenerSesion;
    if(!_mantenerSesion){
      session.email = '';
      session.token = '';
    }

    notifyListeners();
  }

  Future<bool> login() async {
    _isLoading = true;
    notifyListeners();
    final serv = RequestServ.instance;

    final session = UserSession();

    String? userParam = _username;
    String? pwdParam = _password;

    if(session.isPersist){
      userParam = session.email ?? _username;
      pwdParam = session.token ?? _password;

      session.email = userParam;
      session.token = pwdParam;
    }

    // print("=> userParam: $userParam | pwdParam: $pwdParam");

    await Future.delayed(Duration(seconds: 1));

    try{
      ApiResLogin? response = await serv.handlingRequestParsed<ApiResLogin>(
        urlParam: RequestServ.urlvalidaUsuarioEmpresa,
        params: {'correo': userParam, 'contraseña': pwdParam},
        method: 'POST',
        asJson: true,
        fromJson: (json) => ApiResLogin.fromJson(json),
      );
      session.clear();
      // print("=> ${response?.respuesta??false}");

      session.setUserData(response!.usuario.toJson());
      session.setCompanyData(response.empresa.toJson());

      // print("empresa => ${response.empresa.toJson()}");
      // print("getCompanyData => ${session.getCompanyData()}");

      return response?.respuesta??false;
    }catch( excep ){
      print("excep => ${excep}");
      return false;
    }finally{
      notifyListeners();
      _isLoading = false;
    }


  }
}

