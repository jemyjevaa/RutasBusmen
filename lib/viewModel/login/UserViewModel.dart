import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../services/RequestServ.dart';
import '../../../services/ResponseServ.dart';
import '../../../services/UserSession.dart';
import '../../views/widgets/BuildQrProfileWidget.dart';

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
      // session.clear();

      await session.setUserData(response!.usuario.toJson());
      await session.setCompanyData(response.empresa.toJson());
      session.textQR = response.empresa.clave;
      session.lastCompanyClave = response.empresa.clave;
      session.nameQR = response.usuario.nombre;
      session.qrTimestamp = DateTime.now().millisecondsSinceEpoch;

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


  Widget buildSafeQRCodeLogin(String data) {
    if (data.isEmpty) {
      return Icon(
        Icons.qr_code_2,
        size: 120,
        color: Colors.grey[300],
      );
    }

    return Center(
      child: Column(
        children: [
          Text("Nombre: ${UserSession().nameQR}"),
          const SizedBox(height: 6),
          Center(
            child: QrImageView(
              data: data,
              version: QrVersions.auto,
              size: 240,
            ),
          )
        ],
      ),
    );
  }




}

