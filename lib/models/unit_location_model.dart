/// Model for unit location data from unidadDeRuta API
class UnitLocation {
  final int id;
  final String clave; // Unit identifier (e.g., "B1537-SLP")
  final int idplataformagps; // GPS platform ID
  final int positionId;
  final String category; // "bus" or "van"
  final double latitude;
  final double longitude;
  final double? speed;
  final double? course;

  UnitLocation({
    required this.id,
    required this.clave,
    required this.idplataformagps,
    required this.positionId,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.speed,
    this.course,
  });

  factory UnitLocation.fromJson(Map<String, dynamic> json) {
    return UnitLocation(
      id: _parseInt(json['id']),
      clave: json['clave']?.toString() ?? '',
      idplataformagps: _parseInt(json['idplataformagps']),
      positionId: _parseInt(json['positionId']),
      category: json['category']?.toString() ?? 'bus',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      speed: json['speed'] != null ? _parseDouble(json['speed']) : null,
      course: json['course'] != null ? _parseDouble(json['course']) : null,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String get displayName => clave;
}
