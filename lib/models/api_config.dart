/// API Configuration for route requests
/// Contains default values for API parameters
class ApiConfig {
  // Dynamic API parameters (set after login)
  static String? _empresa;
  static int? _idUsuario;
  
  // Default fallback values
  static const String defaultEmpresa = 'lyondellbasell';
  static const int defaultIdUsuario = 11;
  static const String tipoRuta = 'EXT';
  static const String tipoUsuario = 'adm';
  
  // API Endpoints
  static const String baseUrl = 'https://rutasbusmen.geovoy.com/api';
  static const String unidadAsignadaRutaEndpoint = '/unidadAsignadaRuta';
  static const String paradasRutaEndpoint = '/paradasRuta';
  static const String unidadDeRuta = '/unidadDeRuta';
  static const String infoRutaEndpoint = '/ruta';
  
  // Traccar/GPS Endpoints (Replicating Swift)
  static const String devicesEndpoint = '/devices';
  static const String positionsEndpoint = '/positions';
  
  // Basic Auth Credentials (from Swift code)
  static const String gpsUsername = 'usuariosapp';
  static const String gpsPassword = 'usuarios0904';
  
  /// Set the current company (should be called after login)
  static void setEmpresa(String empresa) {
    _empresa = empresa;
  }
  
  /// Set the current user ID (should be called after login)
  static void setIdUsuario(int idUsuario) {
    _idUsuario = idUsuario;
  }
  
  /// Get the current empresa (uses set value or default)
  static String get empresa => _empresa ?? defaultEmpresa;
  
  /// Get the current user ID (uses set value or default)
  static int get idUsuario => _idUsuario ?? defaultIdUsuario;
  
  /// Clear configuration (for logout)
  static void clear() {
    _empresa = null;
    _idUsuario = null;
  }
  
  /// Get the request body for fetching routes
  static Map<String, dynamic> getRouteRequestBody() {
    return {
      'empresa': empresa,
      'idUsuario': idUsuario,
      'tipo_ruta': tipoRuta,
      'tipo_usuario': tipoUsuario,
    };
  }
}
