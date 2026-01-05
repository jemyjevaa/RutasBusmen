import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/UserSession.dart';
import '../services/auth_service.dart';

import '../views/widgets/BuildQrProfileWidget.dart';

enum LoginState {
  initial,
  loading,
  success,
  error,
}

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService;
  
  LoginViewModel({AuthService? authService}) 
      : _authService = authService ?? AuthService();

  // State
  LoginState _state = LoginState.initial;
  String? _errorMessage;
  UserModel? _user;

  // Getters
  LoginState get state => _state;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;
  bool get isLoading => _state == LoginState.loading;

  /// Valida el email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu correo';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un correo válido';
    }
    
    return null;
  }

  /// Valida la contraseña
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    
    if (value.length < 4) {
      return 'La contraseña debe tener al menos 4 caracteres';
    }
    
    return null;
  }

  /// Realiza el login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _setState(LoginState.loading);
      _errorMessage = null;

      print('🔐 Starting login process...');
      
      final user = await _authService.login(
        email: email.trim(),
        password: password,
      );

      _user = user;
      _setState(LoginState.success);
      
      print('✅ Login successful!');
      return true;
    } on AuthException catch (e) {
      print('❌ Auth error: ${e.message}');
      _errorMessage = _getLocalizedErrorMessage(e.message);
      _setState(LoginState.error);
      return false;
    } catch (e) {
      print('❌ Unexpected error: $e');
      _errorMessage = 'Error inesperado. Por favor intenta de nuevo.';
      _setState(LoginState.error);
      return false;
    }
  }

  /// Convierte mensajes de error técnicos a mensajes amigables
  String _getLocalizedErrorMessage(String error) {
    if (error.contains('Dominio no encontrado')) {
      return 'El correo ingresado no está registrado';
    } else if (error.contains('Empresa no válida')) {
      return 'Tu empresa no está activa en el sistema';
    } else if (error.contains('Credenciales incorrectas')) {
      return 'Correo o contraseña incorrectos';
    } else if (error.contains('conexión')) {
      return 'Error de conexión. Verifica tu internet';
    } else {
      return 'Error al iniciar sesión. Intenta de nuevo';
    }
  }

  /// Verifica si hay una sesión guardada
  Future<bool> checkSavedSession() async {
    try {
      final user = await _authService.getSavedUser();
      if (user != null) {
        _user = user;
        _setState(LoginState.success);
        return true;
      }
      return false;
    } catch (e) {
      print('Error checking saved session: $e');
      return false;
    }
  }

  /// Cierra sesión
  Future<void> logout() async {
    try {
      await _authService.logout();
      _user = null;
      _setState(LoginState.initial);
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  /// Limpia el error
  void clearError() {
    _errorMessage = null;
    if (_state == LoginState.error) {
      _setState(LoginState.initial);
    }
  }

  void _setState(LoginState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }


  void openQrMercadoLibreSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        final qr = UserSession().textQR;

        if (qr == null || qr.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text('No hay QR registrado'),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: buildSafeQRCode(qr),
        );
      },
    );
  }

}
