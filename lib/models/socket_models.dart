class SocketPosition {
  final String unitId;
  final String routeKey;
  final String company;
  final double latitude;
  final double longitude;
  final double speed;
  final double heading;
  final String? destination;
  final bool isInRoute;

  SocketPosition({
    required this.unitId,
    required this.routeKey,
    required this.company,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.heading,
    this.destination,
    required this.isInRoute,
  });

  factory SocketPosition.fromJson(Map<String, dynamic> json) {
    return SocketPosition(
      unitId: json['unit_id'] ?? json['unitId'] ?? '',
      routeKey: json['route_key'] ?? json['routeKey'] ?? '',
      company: json['company'] ?? json['empresa'] ?? '',
      latitude: (json['latitude'] ?? json['lat'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? json['lng'] ?? 0.0).toDouble(),
      speed: (json['speed'] ?? json['velocidad'] ?? 0.0).toDouble(),
      heading: (json['heading'] ?? json['direccion'] ?? 0.0).toDouble(),
      destination: json['destination'] ?? json['destino'],
      isInRoute: json['is_in_route'] ?? json['enRuta'] ?? false,
    );
  }
}
