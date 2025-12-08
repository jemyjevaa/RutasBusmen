class SocketPosition {
  final String unitId;
  final double latitude;
  final double longitude;
  final double heading;
  final double speed;
  final bool ignitionStatus;

  SocketPosition({
    required this.unitId,
    required this.latitude,
    required this.longitude,
    required this.heading,
    required this.speed,
    required this.ignitionStatus,
  });

  factory SocketPosition.fromJson(Map<String, dynamic> json) {
    return SocketPosition(
      unitId: json['unit_id']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      heading: (json['heading'] as num?)?.toDouble() ?? 0.0,
      speed: (json['speed'] as num?)?.toDouble() ?? 0.0,
      ignitionStatus: json['ignition_status'] ?? false,
    );
  }
}

class BusUnit {
  final String id;
  final String name;

  BusUnit({required this.id, required this.name});
}
