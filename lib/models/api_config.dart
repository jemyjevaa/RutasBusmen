/// API Configuration for route requests
/// Contains default values for API parameters
class ApiConfig {
  // Default API parameters
  static const String empresa = 'lyondellbasell';
  static const int idUsuario = 11;
  static const String tipoRuta = 'EXT';
  static const String tipoUsuario = 'adm';
  
  // API Endpoints
  static const String baseUrl = 'https://rutasbusmen.geovoy.com/api';
  static const String unidadAsignadaRutaEndpoint = '/unidadAsignadaRuta';
  static const String paradasRutaEndpoint = '/paradasRuta';
  
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
