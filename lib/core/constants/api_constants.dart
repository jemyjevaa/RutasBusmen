class ApiConstants {
  // Base URLs - estas deberían venir de un servidor de configuración
  // Base URLs
  static const String baseUrlAdmin = 'https://lectorasadmintemsa.geovoy.com/';
  static const String baseUrlOptions = 'https://lectorastemsa.geovoy.com/';
  
  // Mantenemos baseUrl genérica apuntando a options por defecto
  static const String baseUrl = baseUrlOptions;
  static const String baseUrl2 = baseUrlOptions; // Para rastreo/sesion
  static const String baseUrlServers = 'https://status.geovoy.com/';
  
  // Endpoints
  static const String validaUsuarioEmpresa = 'api/validaUsuarioEmpresa';
  static const String sesionGps = 'api/session';
  static const String datosServers = 'api/datosservidores';
  static const String unidadAsignadaRuta = 'api/unidadAsignadaRuta';
  static const String positions = 'api/positions';
  static const String devices = 'api/devices';
  static const String paradasRuta = 'api/paradasRuta';
  static const String unidadDeRuta = 'api/unidadDeRuta';
  static const String encuesta = 'api/encuesta';
  static const String sugerencias = 'api/sugerencias';
  static const String infoRuta = 'api/ruta';
  static const String getNotificacion = 'api/notificacionporempresa';
  
  // Login específicos (basado en el código Swift)
  static const String validarDominio = 'api/validarDominio';
  static const String validarEmpresa = 'api/validarempresa';
  static const String validarUsuario = 'api/validarusuario';
  
  // Credenciales para sesión GPS
  static const String gpsEmail = 'usuariosapp';
  static const String gpsPassword = 'usuarios0904';
}
