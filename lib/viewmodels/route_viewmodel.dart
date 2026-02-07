import 'dart:async'; // For Timer
import 'dart:math'; // For cos, sin
import 'dart:io'; // For Platform check
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
import '../services/eta_native_service.dart'; // For native ETA display
import '../services/route_history_service.dart'; // Added

/// ViewModel for managing route data and state
class RouteViewModel extends ChangeNotifier {
  final RouteApiService _apiService = RouteApiService();
  final ETANativeService _etaNativeService = ETANativeService();
  final RouteHistoryService _historyService = RouteHistoryService();

  // State variables 
  List<RouteData> _allRoutes = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Persistence state
  List<int> _recentRouteIds = [];
  List<int> _favoriteRouteIds = [];
  bool _showETAOutsideApp = false;
  bool _hasShownNativeTutorial = false;
  bool _wantsNativeETA = false; // Persistent intent to use the feature
  bool _isActivatingFeature = false; // Flag to auto-enable when perms granted

  List<RouteData> get allRoutes => _allRoutes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get showETAOutsideApp => _showETAOutsideApp;
  bool get hasShownNativeTutorial => _hasShownNativeTutorial;
  bool get wantsNativeETA => _wantsNativeETA;

  void toggleShowETAOutsideApp(bool value) async {
    if (value && Platform.isAndroid) {
      bool hasPermissions = await _etaNativeService.checkAndroidPermissions();
      if (!hasPermissions) {
        // If trying to enable without permissions, we don't update state here
        // The View layer should handle showing the tutorial
        return;
      }
    }
    
    _showETAOutsideApp = value;
    if (!value) {
      _etaNativeService.stopETADisplay();
    }
    _historyService.setShowETAPreference(value);
    notifyListeners();
  }

  /// Sync the feature state with actual system permissions
  Future<void> syncBackgroundActivityState() async {
    bool hasPermissions = true;
    if (Platform.isAndroid) {
      hasPermissions = await _etaNativeService.checkAndroidPermissions();
    }
    
    bool stateChanged = false;
    
    if (_showETAOutsideApp && !hasPermissions) {
      // Revoked permissions -> Turn OFF
      _showETAOutsideApp = false;
      stateChanged = true;
    } else if (hasPermissions && (_isActivatingFeature || _wantsNativeETA)) {
      // Permissions granted and user wants the feature -> Turn ON
      if (!_showETAOutsideApp) {
        _showETAOutsideApp = true;
        await _historyService.setShowETAPreference(true);
        _isActivatingFeature = false;
        stateChanged = true;
      }
    }

    if (stateChanged) {
      notifyListeners();
      
      // If we just turned on the feature and are tracking a route, start it instantly
      if (_showETAOutsideApp && _currentRoute != null && _isUnitInRoute) {
        _fetchUnits(_currentRoute!); // Re-trigger fetch to start display
      }
    }
  }

  /// Mark that the user explicitly wants to enable the native ETA feature.
  /// This is called from the tutorial 'Activate' button.
  Future<void> markWantsNativeETA(bool wants) async {
    _wantsNativeETA = wants;
    await _historyService.setWantsNativeETAPreference(wants);
    if (wants) {
      _isActivatingFeature = true; // Temporary flag for this session's auto-enable
    }
    notifyListeners();
  }

  void setActivatingFeature(bool activating) {
    _isActivatingFeature = activating;
  }

  Future<void> setTutorialShown(bool shown) async {
    _hasShownNativeTutorial = shown;
    await _historyService.setTutorialShown(shown);
    notifyListeners();
  }

  /// Get the last 4 routes selected by the user
  List<RouteData> get frequentRoutes {
    if (_allRoutes.isEmpty) return [];
    return _recentRouteIds
        .map((id) => _allRoutes.cast<RouteData?>().firstWhere((r) => r?.id == id, orElse: () => null))
        .whereType<RouteData>()
        .toList();
  }

  /// Get routes marked as favorite
  List<RouteData> get favoriteRoutes {
    if (_allRoutes.isEmpty) return [];
    return _allRoutes.where((r) => _favoriteRouteIds.contains(r.id)).toList();
  }

  /// Check if a route is favorite
  bool isFavorite(int routeId) => _favoriteRouteIds.contains(routeId);

  /// Toggle favorite status
  Future<void> toggleFavorite(RouteData route) async {
    await _historyService.toggleFavorite(route.id);
    await loadRoutePersistence();
  }

  /// Load recents and favorites from storage
  Future<void> loadRoutePersistence() async {
    _recentRouteIds = await _historyService.getHistory();
    _favoriteRouteIds = await _historyService.getFavorites();
    _hasShownNativeTutorial = await _historyService.hasShownTutorial();
    _showETAOutsideApp = await _historyService.getShowETAPreference();
    _wantsNativeETA = await _historyService.getWantsNativeETAPreference();
    
    // Sync with actual system permissions
    await syncBackgroundActivityState();
    
    notifyListeners();
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
        await loadRoutePersistence(); // Load persistence after routes are loaded
        _errorMessage = null;
      } else {
        _errorMessage = 'No se pudieron cargar las rutas';
        _allRoutes = [];
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

  /// Request location permission explicitly
  Future<void> requestLocationPermission() async {
    await _determinePosition();
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
      case 3:
        return favoriteRoutes;
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
        // use the dots themselves as the path (connect the dots)
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
  StreamSubscription<Position>? _backgroundLocationSubscription; // For iOS background persistence
  List<UnitLocation> _units = [];
  final Map<int, List<LatLng>> _unitTrails = {}; // Track history of positions for each unit
  bool _isUnitInRoute = false;
  String _currentDestination = '';
  String _nameUnit = '';
  String _timeUnitUser = '00';
  RouteData? _currentRoute;


  List<UnitLocation> get units => _units;
  Map<int, List<LatLng>> get unitTrails => _unitTrails;
  bool get isUnitInRoute => _isUnitInRoute;
  String get currentDestination => _currentDestination;
  String get timeUnitUser => _timeUnitUser;
  String get nameUnit => _nameUnit;

  /// Start tracking a route
  void startTracking(RouteData route) {
    // print('🚀 Starting tracking for route: ${route.claveRuta}');
    stopTracking(); // Stop any existing tracking

    _currentRoute = route; // Store current route
    
    // Add to history and reload
    _historyService.addToHistory(route.id).then((_) {
      loadRoutePersistence();
    });

    // Start a background location stream for iOS to keep the app alive
    if (Platform.isIOS) {
      _backgroundLocationSubscription = Geolocator.getPositionStream(
        locationSettings: AppleSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
          allowBackgroundLocationUpdates: true,
          showBackgroundLocationIndicator: false,
        ),
      ).listen((Position position) {
        // We don't need to do anything with the position here,
        // the existence of the stream with allowBackgroundLocationUpdates: true
        // is what keeps the app alive on iOS.
      });
    }

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
    
    _backgroundLocationSubscription?.cancel();
    _backgroundLocationSubscription = null;

    _units = [];
    _unitTrails.clear();
    _isUnitInRoute = false;
    _currentDestination = '';
    _nameUnit = '';
    _currentRoute = null;
    
    // Stop native ETA display
    _etaNativeService.stopETADisplay();
    
    notifyListeners();
  }

  /// Fetch units for the route
  Future<void> _fetchUnits(RouteData route) async {
    try {
      // Check if route is active (within schedule)
      if (!route.isActiveNow()) {
        _units = [];
        _unitTrails.clear();
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

      double unitLat = 0.0;
      double unitLon = 0.0;


      if (units.isNotEmpty) {
        _isUnitInRoute = true;

        // Enrich unit data with real-time position from Traccar
        for (var i = 0; i < _units.length; i++) {
           final unit = _units[i];
           // Fetch device details to get positionId
           final deviceData = await _apiService.getDeviceDetails(unit.idplataformagps);
           print("deviceData => $deviceData");
           if (deviceData != null) {
             final positionId = deviceData['positionId'] as int?;
             if (positionId != null) {
               // Fetch position details
               final positionData = await _apiService.getDevicePosition(positionId);
               if (positionData != null) {
                 // Update unit with real-time data
                 unitLat = positionData['latitude'] as double? ?? unit.latitude;
                 unitLon = positionData['longitude'] as double? ?? unit.longitude;
                 print("unitLat => $unitLat | unitLon => $unitLon");
                 // Update trail history
                 _updateUnitTrail(unit.id, unitLat, unitLon);

                 _units[i] = unit.copyWith(
                   latitude: unitLat,
                   longitude: unitLon,
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
           _nameUnit = _units.first.clave;
           
           // Safe position fetching to prevent crashes on Android
           Position? userPosition = await _determinePosition();

           if (userPosition != null) {

             int minutes = calculateTimeBetweenUnitToUser(
               unitLat, unitLon,
               userPosition.latitude, userPosition.longitude
             );

             print("calculateTimeBetweenUnitToUser => $unitLat | $unitLon | ${userPosition.latitude} | ${userPosition.longitude} => total ${minutes.toString().padLeft(2, '0')}");

             _timeUnitUser = minutes.toString().padLeft(2, '0');
           } else {
             _timeUnitUser = '00';
           }
        } else {
           _currentDestination = route.displayName;
        }
      } else {
        _isUnitInRoute = false;
        _currentDestination = 'Sin unidades asignadas';
        _timeUnitUser = '00';
      }

      // Start or update native ETA display
      if (_currentRoute != null && _isUnitInRoute && _showETAOutsideApp) {
        final etaMinutes = int.tryParse(_timeUnitUser) ?? 0;
        final tripId = '${_currentRoute!.claveRuta}_${DateTime.now().millisecondsSinceEpoch ~/ 1000}';
        
        if (!_etaNativeService.isActive) {
          // Start native display
          _etaNativeService.startETADisplay(
            tripId: tripId,
            routeName: _currentRoute!.displayName,
            eta: etaMinutes,
            status: _currentDestination,
          );
        } else {
          // Update existing display
          _etaNativeService.updateETA(
            eta: etaMinutes,
            status: _currentDestination,
          );
        }
      }

      notifyListeners();

    } catch (e) {
      print('❌ Error fetching units: $e');
    }
  }

  void _updateUnitTrail(int unitId, double lat, double lon) {
    if (!_unitTrails.containsKey(unitId)) {
      _unitTrails[unitId] = [];
    }
    final trail = _unitTrails[unitId]!;
    final newPos = LatLng(lat, lon);
    
    // Only add if it's different from the last one to avoid duplicates
    if (trail.isEmpty || (trail.last.latitude != lat || trail.last.longitude != lon)) {
      trail.add(newPos);
      // Limit trail length to last 50 points to preserve history better
      if (trail.length > 50) {
        trail.removeAt(0);
      }
    }
  }

  /// Calculate a point ahead of the unit based on its course (heading)
  LatLng calculateHeadingPoint(double lat, double lon, double? course, {double distance = 0.002}) {
    if (course == null) return LatLng(lat, lon);
    
    // Convert course to radians
    final double angleRad = course * (pi / 180.0);
    
    // Calculate new position
    // Note: Lat/Lon distance calculation is approximate but sufficient for small distances
    final double dLat = distance * cos(angleRad);
    final double dLon = distance * sin(angleRad) / cos(lat * pi / 180.0);
    
    return LatLng(lat + dLat, lon + dLon);
  }

  /// Get the remaining part of the route path from the unit's current position to the end
  List<LatLng> getRemainingRoutePath(double unitLat, double unitLon) {
    if (_routePath.isEmpty) return [];
    
    // Find index of the closest point on the route path
    int closestIndex = 0;
    double minDistance = double.infinity;
    
    for (int i = 0; i < _routePath.length; i++) {
      double d = Geolocator.distanceBetween(
        unitLat, unitLon,
        _routePath[i].latitude, _routePath[i].longitude
      );
      if (d < minDistance) {
        minDistance = d;
        closestIndex = i;
      }
    }
    
    List<LatLng> result = [LatLng(unitLat, unitLon)];
    // Add all points from the closest index onwards
    for (int i = closestIndex; i < _routePath.length; i++) {
      result.add(LatLng(_routePath[i].latitude, _routePath[i].longitude));
    }
    return result;
  }

  /// Obtiene una "estela" corta de los próximos puntos de la ruta
  List<LatLng> getHeadingTrail(double unitLat, double unitLon) {
    final fullPath = getRemainingRoutePath(unitLat, unitLon);
    if (fullPath.length > 1) {
      // Tomamos los primeros 8 puntos para crear una "estela" hacia adelante
      return fullPath.take(8).toList();
    }
    return [];
  }

  /// Calculate estimated time in minutes between two points
  int calculateTimeBetweenUnitToUser(double lat1, double lon1, double lat2, double lon2) {
    double distanceInMeters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
    // Average speed 30 km/h = 8.33 m/s
    double averageSpeedMps = 8.33;
    double timeInSeconds = distanceInMeters / averageSpeedMps;
    return (timeInSeconds / 60).round();
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

  /// Determina la posición actual del dispositivo manejando permisos y servicios.
  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si los servicios de ubicación están habilitados.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return null;
    } 

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (e) {
      // Fallback a la última posición conocida si falla el timeout o hay error
      return await Geolocator.getLastKnownPosition();
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
