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
  final String? destination; // NUEVO
  final bool isInRoute;      // NUEVO

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
    this.destination,
    required this.isInRoute,
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
      destination: json['destination'] ?? json['destino'],
      isInRoute: json['is_in_route'] ?? json['enRuta'] ?? false,
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

  UnitLocation copyWith({
    int? id,
    String? clave,
    int? idplataformagps,
    int? positionId,
    String? category,
    double? latitude,
    double? longitude,
    double? speed,
    double? course,
    String? destination,
    bool? isInRoute,
  }) {
    return UnitLocation(
      id: id ?? this.id,
      clave: clave ?? this.clave,
      idplataformagps: idplataformagps ?? this.idplataformagps,
      positionId: positionId ?? this.positionId,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speed: speed ?? this.speed,
      course: course ?? this.course,
      destination: destination ?? this.destination,
      isInRoute: isInRoute ?? this.isInRoute,
    );
  }

  String get displayName => clave;
}
