import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/unit_location_model.dart';
import '../models/route_stop_model.dart';
import '../models/api_config.dart';
import 'route_api_service.dart'; // Import RouteApiService

/// Service for tracking units in real-time
/// Uses "Smart Polling" to fetch unit positions periodically
/// This mimics the behavior of the Swift app which uses HTTP polling
class TrackingService {
  final RouteApiService _apiService = RouteApiService();
  
  // Stream controllers
  final _unitPositionController = StreamController<UnitLocation>.broadcast();
  final _routeStopsController = StreamController<List<RouteStopModel>>.broadcast();
  
  // Public streams
  Stream<UnitLocation> get unitPositionStream => _unitPositionController.stream;
  Stream<List<RouteStopModel>> get routeStopsStream => _routeStopsController.stream;
  
  bool _isInitialized = false;
  String _currentRouteKey = '';
  String _currentCompany = '';
  Timer? _pollingTimer;
  bool _isPolling = false;
  
  /// Initialize the tracking service
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    print('🚀 TrackingService initialized (Smart Polling Mode)');
  }
  
  /// Start tracking a specific route
  Future<void> startTrackingRoute(String routeKey, String company) async {
    _currentRouteKey = routeKey;
    _currentCompany = company;
    
    print('🚌 Started tracking route: $routeKey for company: $company');
    
    // Fetch static stops once
    await _fetchRouteStops(routeKey);
    
    // Start polling for unit positions
    _startPolling();
  }
  
  /// Stop tracking current route
  void stopTracking() {
    _currentRouteKey = '';
    _currentCompany = '';
    _stopPolling();
    print('🛑 Tracking stopped');
  }
  
  void _startPolling() {
    if (_isPolling) return;
    _isPolling = true;
    
    print('🔄 Starting polling for unit positions...');
    
    // Immediate first fetch
    _fetchUnitPositions();
    
    // Schedule periodic fetches (every 3 seconds, similar to Swift app likely behavior)
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentRouteKey.isNotEmpty) {
        _fetchUnitPositions();
      }
    });
  }
  
  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
  }
  
  Future<void> _fetchUnitPositions() async {
    if (_currentRouteKey.isEmpty) return;
    
    try {
      // 1. Get assigned units for the route
      final units = await _apiService.fetchUnitsForRoute(_currentRouteKey);
      
      if (units.isNotEmpty) {
        // Process each unit found
        for (var unitBase in units) {
          // 2. Get Device Info (Optional, mostly for status/online check)
          // Swift: serviceDevice(idUnidad) -> uses idplataformagps
          // We might skip this if we just want position, but let's check if we need it.
          // The Swift code gets device data but mostly uses it for status.
          
          // 3. Get Position Info
          // Swift: servicePosition(idUnidad) -> uses positionId from unitBase
          // Note: unitBase.positionId comes from the first call
          
          if (unitBase.positionId > 0) {
            final positionData = await _apiService.fetchPosition(unitBase.positionId);
            
            if (positionData != null) {
              // Merge data
              final updatedUnit = UnitLocation(
                id: unitBase.id,
                clave: unitBase.clave,
                idplataformagps: unitBase.idplataformagps,
                positionId: unitBase.positionId,
                category: unitBase.category,
                latitude: (positionData['latitude'] ?? 0.0).toDouble(),
                longitude: (positionData['longitude'] ?? 0.0).toDouble(),
                speed: (positionData['speed'] ?? 0.0).toDouble(),
                course: (positionData['course'] ?? 0.0).toDouble(),
                destination: unitBase.destination, // Keep existing or update if available
                isInRoute: true, // Assume true if we have a position
              );
              
              print('📍 Unit ${updatedUnit.clave} updated via Chain: ${updatedUnit.latitude}, ${updatedUnit.longitude}');
              _unitPositionController.add(updatedUnit);
            }
          }
        }
      }
    } catch (e) {
      print('⚠️ Error polling unit positions: $e');
    }
  }
  
  /// Fetch static route stops (HTTP - One time only)
  Future<void> _fetchRouteStops(String routeKey) async {
    try {
      final response = await _apiService.fetchRouteStops(routeKey);
      
      if (response.respuesta) {
        _routeStopsController.add(response.data);
        // print('🚏 Loaded ${response.data.length} stops for route $routeKey');
      }
    } catch (e) {
      print('⚠️ Error fetching route stops: $e');
    }
  }
  
  /// Dispose resources
  void dispose() {
    _stopPolling();
    _unitPositionController.close();
    _routeStopsController.close();
    print('🛑 TrackingService disposed');
  }
}
