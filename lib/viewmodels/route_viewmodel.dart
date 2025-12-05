import 'package:flutter/foundation.dart';
import '../models/route_model.dart';
import '../models/route_stop_model.dart';
import '../services/route_api_service.dart';

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
    // TODO: Implement user-specific frequent routes
    // For now, return first 2 routes as "frequent"
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

  List<RouteStop> _routeStops = [];
  bool _isLoadingStops = false;
  
  List<RouteStop> get routeStops => _routeStops;
  bool get isLoadingStops => _isLoadingStops;

  /// Fetch stops for a specific route
  Future<void> fetchStopsForRoute(String claveRuta) async {
    print('Fetching stops for route: $claveRuta'); // DEBUG LOG
    _isLoadingStops = true;
    _routeStops = []; // Clear previous stops
    notifyListeners();

    try {
      final response = await _apiService.fetchRouteStops(claveRuta);
      
      if (response.respuesta) {
        _routeStops = response.data;
        print('Loaded ${_routeStops.length} stops'); // DEBUG LOG
        // Sort by order if available
        _routeStops.sort((a, b) => (a.orden ?? 0).compareTo(b.orden ?? 0));
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
}