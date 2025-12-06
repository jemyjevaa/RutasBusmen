class RoutePathPoint {
  final double latitude;
  final double longitude;
  
  RoutePathPoint({required this.latitude, required this.longitude});
  
  factory RoutePathPoint.fromJson(Map<String, dynamic> json) {
    return RoutePathPoint(
      latitude: double.tryParse(json['latitud']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['longitud']?.toString() ?? '0') ?? 0.0,
    );
  }
}
