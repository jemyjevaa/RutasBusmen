/// Model for route stops (points that define the route path)
class RouteStopResponse {
  final bool respuesta;
  final List<RouteStopModel> data;

  RouteStopResponse({
    required this.respuesta,
    required this.data,
  });

  factory RouteStopResponse.fromJson(Map<String, dynamic> json) {
    return RouteStopResponse(
      respuesta: json['respuesta'] as bool? ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => RouteStopModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class RouteStopModel {
  final double latitude;
  final double longitude;
  final int? id;
  final int? orden;
  final String? name;
  final String? hora_parada;
  final String? description;
  final int? numeroParada;

  RouteStopModel({
    required this.latitude,
    required this.longitude,
    this.id,
    this.orden,
    this.name,
    this.hora_parada,
    this.description,
    this.numeroParada,
  });

  factory RouteStopModel.fromJson(Map<String, dynamic> json) {
    // Handle string or number inputs for coordinates
    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return RouteStopModel(
      latitude: parseDouble(json['latitud'] ?? json['latitude'] ?? json['Latitud']),
      longitude: parseDouble(json['longitud'] ?? json['longitude'] ?? json['Longitud']),
      id: json['id'] as int?,
      orden: json['orden'] as int?,
      name: json['nombre'] as String? ?? json['name'] as String?,
      hora_parada: json['hora_parada'] as String? ?? json['hora_parada'] as String?,
      description: json['descripcion'] as String? ?? json['description'] as String?,
      numeroParada: json['numero_parada'] as int?,
    );
  }
}
