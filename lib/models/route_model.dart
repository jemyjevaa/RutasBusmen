/// Route models based on API response structure
/// Converted from Swift ItemRutas model

/// Main response wrapper
class RouteResponse {
  final bool respuesta;
  final List<RouteData> data;

  RouteResponse({
    required this.respuesta,
    required this.data,
  });

  factory RouteResponse.fromJson(Map<String, dynamic> json) {
    return RouteResponse(
      respuesta: json['respuesta'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((item) => RouteData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'respuesta': respuesta,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

/// Individual route data
class RouteData {
  final int id;
  final String nombreRuta;
  final String turnoRuta;
  final String direccionRuta;
  final String claveRuta;
  final List<String> diaRuta;
  final String horaInicioRuta;
  final String horaFinRuta;
  final String tipoRuta;

  RouteData({
    required this.id,
    required this.nombreRuta,
    required this.turnoRuta,
    required this.direccionRuta,
    required this.claveRuta,
    required this.diaRuta,
    required this.horaInicioRuta,
    required this.horaFinRuta,
    required this.tipoRuta,
  });

  factory RouteData.fromJson(Map<String, dynamic> json) {
    return RouteData(
      id: json['id'] as int,
      nombreRuta: json['nombre_ruta'] as String,
      turnoRuta: json['turno_ruta'] as String,
      direccionRuta: json['direccion_ruta'] as String,
      claveRuta: json['clave_ruta'] as String,
      diaRuta: (json['dia_ruta'] as List<dynamic>)
          .map((item) => item as String)
          .toList(),
      horaInicioRuta: json['hora_inicio_ruta'] as String,
      horaFinRuta: json['hora_fin_ruta'] as String,
      tipoRuta: json['tipo_ruta'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_ruta': nombreRuta,
      'turno_ruta': turnoRuta,
      'direccion_ruta': direccionRuta,
      'clave_ruta': claveRuta,
      'dia_ruta': diaRuta,
      'hora_inicio_ruta': horaInicioRuta,
      'hora_fin_ruta': horaFinRuta,
      'tipo_ruta': tipoRuta,
    };
  }

  /// Check if route is currently active based on time
  bool isActiveNow() {
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    // Simple string comparison works for HH:MM format
    return currentTime.compareTo(horaInicioRuta) >= 0 && 
           currentTime.compareTo(horaFinRuta) <= 0;
  }

  /// Get display name with direction
  String get displayName {
    return '$nombreRuta - $direccionRuta';
  }

  /// Get time range display
  String get timeRange {
    return '$horaInicioRuta - $horaFinRuta';
  }
}
