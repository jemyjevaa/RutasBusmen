/// Model for route stops (points that define the route path)
class RouteStopResponse {
  final bool respuesta;
  final List<RouteStop> data;

  RouteStopResponse({
    required this.respuesta,
    required this.data,
  });

  factory RouteStopResponse.fromJson(Map<String, dynamic> json) {
    return RouteStopResponse(
      respuesta: json['respuesta'] as bool? ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => RouteStop.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class RouteStop {
  final double latitud;
  final double longitud;
  final int? orden;
  final String? nombre;

  RouteStop({
    required this.latitud,
    required this.longitud,
    this.orden,
    this.nombre,
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    // Handle string or number inputs for coordinates
    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return RouteStop(
      latitud: parseDouble(json['latitud'] ?? json['latitude'] ?? json['Latitud']),
      longitud: parseDouble(json['longitud'] ?? json['longitude'] ?? json['Longitud']),
      orden: json['orden'] as int?,
      nombre: json['nombre'] as String? ?? json['name'] as String?,
    );
  }
}
