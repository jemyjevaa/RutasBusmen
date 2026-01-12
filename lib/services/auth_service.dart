import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/login_response.dart';
import '../models/server_model.dart';
import '../core/constants/api_constants.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  
  AuthService({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();

  /// 1. Valida el dominio del correo
  Future<ValidateDomainResponse> validateDomain(String email) async {
    try {
      final response = await _apiService.post(
        endpoint: ApiConstants.validarDominio,
        baseUrl: ApiConstants.baseUrlAdmin, // Usa URL Admin
        body: {'correo': email},
      );
      return ValidateDomainResponse.fromJson(response);
    } catch (e) {
      throw AuthException('Error al validar dominio: ${e.toString()}');
    }
  }

  /// 2. Valida la empresa
  Future<ValidateCompanyResponse> validateCompany(String idEmpresa) async {
    try {
      final response = await _apiService.post(
        endpoint: ApiConstants.validarEmpresa,
        baseUrl: ApiConstants.baseUrlAdmin, // Usa URL Admin
        body: {'idempresa': idEmpresa},
      );
      return ValidateCompanyResponse.fromJson(response);
    } catch (e) {
      throw AuthException('Error al validar empresa: ${e.toString()}');
    }
  }

  /// 3. Valida el usuario con sus credenciales
  Future<ValidateUserResponse> validateUser({
    required String email,
    required String password,
    required String idEmpresa,
  }) async {
    try {
      final body = {
        'correo': email,
        'password': password,
        'idempresa': idEmpresa,
      };

      final response = await _apiService.post(
        endpoint: ApiConstants.validarUsuario,
        baseUrl: ApiConstants.baseUrlOptions,
        body: body,
        isUrlEncoded: false,
      );
      
      return ValidateUserResponse.fromJson(response);
    } catch (e) {
      throw AuthException('Error al validar usuario: ${e.toString()}');
    }
  }

  /// 4. Inicia sesión en el sistema GPS para obtener la cookie
  Future<String> initGpsSession() async {
    try {
      final response = await _apiService.postWithHeaders(
        endpoint: ApiConstants.sesionGps,
        baseUrl: ApiConstants.baseUrl2,
        body: {
          'email': ApiConstants.gpsEmail,
          'password': ApiConstants.gpsPassword,
        },
        isUrlEncoded: true,
      );
      
      // Extraer cookie del header 'set-cookie'
      final cookie = response.headers['set-cookie'];
      if (cookie != null) {

        // print('Cookie received: $cookie');
        return cookie;
      }
      
      return '';
    } catch (e) {
      print('Warning: GPS Session failed: $e');
      return ''; 
    }
  }

  /// Proceso completo de login
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Validar dominio
      // print('🔐 Step 1: Validating domain ($email)...');
      final domainResponse = await validateDomain(email);
      
      if (domainResponse.datos.isEmpty) {
        throw AuthException('Dominio no encontrado');
      }
      
      final idEmpresa = domainResponse.datos.first.id;
      // print('✅ Domain validated. Company ID: $idEmpresa');

      // 2. Validar empresa
      // print('🔐 Step 2: Validating company...');
      final companyResponse = await validateCompany(idEmpresa);
      
      if (companyResponse.respuesta.isEmpty) {
        throw AuthException('Empresa no válida');
      }
      // print('✅ Company validated');

      // 3. Validar usuario
      // print('🔐 Step 3: Validating user...');
      final userResponse = await validateUser(
        email: email,
        password: password,
        idEmpresa: idEmpresa,
      );
      
      if (!userResponse.isSuccess) {
        throw AuthException('Credenciales incorrectas');
      }
      
      final userData = userResponse.datos.first;
      // print('✅ User validated');

      // 4. Iniciar sesión GPS
      // print('🔐 Step 4: Initializing GPS session...');
      final cookie = await initGpsSession();
      // print(cookie);
      if (cookie.isNotEmpty) {

        await _saveCookie(cookie);
        // print('✅ GPS session initialized');
      }

      // 5. Guardar datos del usuario
      final user = UserModel(
        id: userData.id,
        nombre: userData.nombre,
        email: userData.email,
        empresa: idEmpresa,
        telefono: userData.telefono,
      );
      
      await _saveUser(user);
      // print('✅ Login completed successfully');
      return user;
    } catch (e) {
      // print('❌ Login failed: $e');
      if (e is AuthException) rethrow;
      throw AuthException('Error en el proceso de login: ${e.toString()}');
    }
  }

  /// Guarda el usuario en SharedPreferences
  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_name', user.nombre);
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_empresa', user.empresa);
    if (user.telefono != null) {
      await prefs.setString('user_phone', user.telefono!);
    }
    await prefs.setBool('is_logged_in', true);
  }

  /// Guarda la cookie en SharedPreferences
  Future<void> _saveCookie(String cookie) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gps_cookie', cookie);
  }

  /// Obtiene el usuario guardado
  Future<UserModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    
    if (!isLoggedIn) return null;
    
    return UserModel(
      id: prefs.getString('user_id') ?? '',
      nombre: prefs.getString('user_name') ?? '',
      email: prefs.getString('user_email') ?? '',
      empresa: prefs.getString('user_empresa') ?? '',
      telefono: prefs.getString('user_phone'),
    );
  }

  /// Cierra sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  void dispose() {
    _apiService.dispose();
  }
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
