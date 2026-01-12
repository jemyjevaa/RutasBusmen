import 'dart:async'; // For Timer
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart'; // For distance calculation
import '../models/route_model.dart';
import '../models/route_stop_model.dart';
import '../models/unit_location_model.dart'; // Added
import '../services/route_api_service.dart';
import '../services/google_directions_service.dart';
import '../models/route_path_point.dart';
import '../models/api_config.dart'; // For ApiConfig
import '../services/UserSession.dart'; // For UserSession
import 'package:google_maps_flutter/google_maps_flutter.dart'; // For LatLng

/// ViewModel for managing route data and state
class RouteViewModel extends ChangeNotifier {
  final RouteApiService _apiService = RouteApiService();

  // State variables 
  List<RouteData> _allRoutes = [];
  bool _isLoading = false;
  String? _errorMessage;

  
  List<RouteData> get allRoutes => _allRoutes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  
  List<RouteData> get frequentRoutes {

    return _allRoutes.take(2).toList();
  }

  /// Get routes that are currently active (En Tiempo)
  List<RouteData> get onTimeRoutes {
    return _allRoutes.where((route) => route.isActiveNow()).toList();
  }

  /// Fetch routes from API
  Future<void> fetchRoutes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.fetchRoutes();
      
      if (response.respuesta) {
        _allRoutes = response.data;
        _errorMessage = null;
      } else {
        _errorMessage = 'No se pudieron cargar las rutas';
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _allRoutes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh routes (pull to refresh)
  Future<void> refreshRoutes() async {
    await fetchRoutes();
  }

  /// Get routes for a specific tab
  /// 0: Frecuentes, 1: En Tiempo, 2: Todas
  List<RouteData> getRoutesForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return frequentRoutes;
      case 1:
        return onTimeRoutes;
      case 2:
        return allRoutes;
      default:
        return allRoutes;
    }
  }

  /// Get unique route names (for grouping in "Todas" tab)
  List<String> getUniqueRouteNames() {
    final names = _allRoutes.map((route) => route.nombreRuta).toSet().toList();
    names.sort();
    return names;
  }

  /// Get routes by name
  List<RouteData> getRoutesByName(String routeName) {
    return _allRoutes
        .where((route) => route.nombreRuta == routeName)
        .toList();
  }

  /// Group routes by direction (Entrada/Salida)
  Map<String, List<RouteData>> getRoutesGroupedByDirection(List<RouteData> routes) {
    final Map<String, List<RouteData>> grouped = {};
    
    for (var route in routes) {
      final direction = route.direccionRuta;
      if (!grouped.containsKey(direction)) {
        grouped[direction] = [];
      }
      grouped[direction]!.add(route);
    }
    
    return grouped;
  }

  /// Sort routes by time (horaInicioRuta)
  List<RouteData> getSortedRoutes(List<RouteData> routes) {
    return List.from(routes)
      ..sort((a, b) => a.horaInicioRuta.compareTo(b.horaInicioRuta));
  }

  // --- Route Stops Logic ---

  List<RouteStopModel> _routeStops = [];
  bool _isLoadingStops = false;
  
  List<RouteStopModel> get routeStops => _routeStops;
  bool get isLoadingStops => _isLoadingStops;

  // --- Route Path Logic ---
  final GoogleDirectionsService _directionsService = GoogleDirectionsService();
  List<RoutePathPoint> _routePath = [];
  List<RoutePathPoint> get routePath => _routePath;

  // Deprecated: logic moved to fetchStopsForRoute
  Future<void> fetchRoutePath(String claveRuta) async {
    // No-op or manual trigger if needed
  }

  Future<void> _fetchPolylineFromGoogle() async {
    if (_routeStops.isEmpty) return;
    
    try {
      final points = await _directionsService.getRoutePolyline(_routeStops);
      _routePath = points.map((p) => RoutePathPoint(latitude: p.latitude, longitude: p.longitude)).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching Google Polyline: $e');
    }
  }

  /// Fetch stops for a specific route
  Future<void> fetchStopsForRoute(String claveRuta) async {
    // print('Fetching stops for route: $claveRuta'); // DEBUG LOG
    _isLoadingStops = true;
    _routeStops = []; // Clear previous stops
    _routePath = []; // Clear previous path
    notifyListeners();

    try {
      final response = await _apiService.fetchRouteStops(claveRuta);
      
      if (response.respuesta) {
        _routeStops = response.data;
        // print('Loaded ${_routeStops.length} stops'); // DEBUG LOG
        // Sort by order if available
        _routeStops.sort((a, b) => (a.orden ?? 0).compareTo(b.orden ?? 0));
        
        // Fetch polyline from Google Directions
        await _fetchPolylineFromGoogle();
        
        // Fallback: If Google Directions failed or returned no points, 
        // use the stops themselves as the path (connect the dots)
        if (_routePath.isEmpty && _routeStops.isNotEmpty) {
          // print('⚠️ Using straight line fallback for route path');
          _routePath = _routeStops
              .map((s) => RoutePathPoint(latitude: s.latitude, longitude: s.longitude))
              .toList();
        }
        
      } else {
        print('No stops found for route $claveRuta (respuesta: false)');
      }
    } catch (e) {
      print('Error fetching stops: $e');
    } finally {
      _isLoadingStops = false;
      notifyListeners();
    }
  }

  /// Clear current stops
  void clearRouteStops() {
    _routeStops = [];
    notifyListeners();
  }

  // --- Tracking Logic ---
  
  Timer? _pollingTimer;
  List<UnitLocation> _units = [];
  bool _isUnitInRoute = false;
  String _currentDestination = '';
  String _timeUnitUser = '00';
  
  List<UnitLocation> get units => _units;
  bool get isUnitInRoute => _isUnitInRoute;
  String get currentDestination => _currentDestination;
  String get timeUnitUser => _timeUnitUser;

  /// Start tracking a route
  void startTracking(RouteData route) {
    // print('🚀 Starting tracking for route: ${route.claveRuta}');
    stopTracking(); // Stop any existing tracking
    
    // Initial fetch
    _fetchUnits(route);
    
    // Poll every 3 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _fetchUnits(route);
    });
  }

  /// Stop tracking
  void stopTracking() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _units = [];
    _isUnitInRoute = false;
    _currentDestination = '';
    notifyListeners();
  }

  /// Fetch units for the route
  Future<void> _fetchUnits(RouteData route) async {
    try {
      // Check if route is active (within schedule)
      if (!route.isActiveNow()) {
        _units = [];
        _isUnitInRoute = false;
        _currentDestination = 'Fuera de horario';
        notifyListeners();
        return;
      }
      
      final session = UserSession();
      final empresa = session.getCompanyData()?.clave ?? 'lyondellbasell';
      
      // Use the existing _apiService
      final units = await _apiService.getUnitsForRoute(empresa, route.claveRuta);
      
      _units = units;
      
      if (units.isNotEmpty) {
        _isUnitInRoute = true;
        
        // Enrich unit data with real-time position from Traccar
        for (var i = 0; i < _units.length; i++) {
           final unit = _units[i];
           // Fetch device details to get positionId
           final deviceData = await _apiService.getDeviceDetails(unit.idplataformagps);
           if (deviceData != null) {
             final positionId = deviceData['positionId'] as int?;
             if (positionId != null) {
               // Fetch position details
               final positionData = await _apiService.getDevicePosition(positionId);
               if (positionData != null) {
                 // Update unit with real-time data
                 _units[i] = unit.copyWith(
                   latitude: positionData['latitude'] as double? ?? unit.latitude,
                   longitude: positionData['longitude'] as double? ?? unit.longitude,
                   speed: (positionData['speed'] as num?)?.toDouble() ?? 0.0,
                   course: (positionData['course'] as num?)?.toDouble() ?? 0.0,
                 );
               }
             }
           }
        }
        
        // Update banner with next stop info
        if (_routeStops.isNotEmpty) {
           _currentDestination = _getNextStopName(_units.first);
           // Get time unit are to user
        } else {
           _currentDestination = route.displayName;
        }
      } else {
        _isUnitInRoute = false;
        _currentDestination = 'Sin unidades asignadas';
      }
      
      notifyListeners();
      
    } catch (e) {
      print('❌ Error fetching units: $e');
    }
  }

  /// Calculate next stop for the unit
  String _getNextStopName(UnitLocation unit) {
    if (_routeStops.isEmpty) return '';
    
    // Find the closest stop
    double minDistance = double.infinity;
    String closestStopName = '';
    int closestStopIndex = -1;
    
    for (int i = 0; i < _routeStops.length; i++) {
      final stop = _routeStops[i];
      final distance = Geolocator.distanceBetween(
        unit.latitude, unit.longitude, 
        stop.latitude, stop.longitude
      );
      
      if (distance < minDistance) {
        minDistance = distance;
        closestStopName = stop.name ?? '';
        closestStopIndex = i;
      }
    }
    
    if (closestStopIndex != -1) {
      final stop = _routeStops[closestStopIndex];
      // return 'UNIDAD ${unit.clave} : PARADA ${stop.numeroParada ?? (closestStopIndex + 1)} ${stop.name}';
      return ' PARADA ${stop.numeroParada ?? (closestStopIndex + 1)} ${stop.name}';
    }
    
    return '';
  }

  @override
  void dispose() {
    super.dispose();
  }
}