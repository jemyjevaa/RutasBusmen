import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/socket_models.dart';
import '../services/socket_service.dart';

class MapProvider extends ChangeNotifier {
  final SocketService _socketService = SocketService();
  
  // State
  Set<Marker> _markers = {};
  List<String> _assignedUnitIds = [];
  bool _isTracking = false;
  
  // Getters
  Set<Marker> get markers => _markers;
  bool get isTracking => _isTracking;

  // Icons
  BitmapDescriptor? _busIconOn;
  BitmapDescriptor? _busIconOff;

  StreamSubscription? _socketSubscription;

  MapProvider() {
    _loadIcons();
  }

  Future<void> _loadIcons() async {
    // Load your custom icons here
    // For now using default marker with different hues
    _busIconOn = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    _busIconOff = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    
    // In a real app, load assets:
    // _busIconOn = await BitmapDescriptor.fromAssetImage(...);
  }

  /// Step 2: Set assigned units for the selected route
  void setAssignedUnits(List<String> unitIds) {
    _assignedUnitIds = unitIds;
    _markers.clear(); // Clear previous route markers
    notifyListeners();
  }

  /// Step 4: Connect and start listening
  void startTracking(String socketUrl) {
    if (_isTracking) return;
    
    _socketService.connect(socketUrl);
    _isTracking = true;

    _socketSubscription = _socketService.positionStream.listen((position) {
      _handleSocketPosition(position);
    });
  }

  void stopTracking() {
    _socketSubscription?.cancel();
    _socketService.disconnect();
    _isTracking = false;
    _markers.clear();
    notifyListeners();
  }

  /// Step 5: Core Filtering and Update Logic
  void _handleSocketPosition(SocketPosition position) {
    // 1. Filtrado: Verificar si el unit_id está en la lista de asignados
    if (!_assignedUnitIds.contains(position.unitId)) {
      // 2. Descarte: Si no está, ignorar
      return;
    }

    // 3. Actualización: Si coincide, actualizar marcador
    _updateMarker(position);
  }

  void _updateMarker(SocketPosition position) {
    final markerId = MarkerId(position.unitId);
    
    // Determine icon based on ignition status
    final icon = position.ignitionStatus 
        ? (_busIconOn ?? BitmapDescriptor.defaultMarker)
        : (_busIconOff ?? BitmapDescriptor.defaultMarker);

    // Create or update marker
    // Note: For smooth animation, we would ideally use a separate AnimationController
    // or a package like 'flutter_animarker'. 
    // Here we update the position directly for simplicity in this architectural example.
    
    final marker = Marker(
      markerId: markerId,
      position: LatLng(position.latitude, position.longitude),
      rotation: position.heading,
      icon: icon,
      infoWindow: InfoWindow(
        title: 'Unit ${position.unitId}',
        snippet: 'Speed: ${position.speed} km/h',
      ),
      anchor: const Offset(0.5, 0.5), // Center the icon
      flat: true, // Flat against the map for rotation
    );

    // Update the set of markers
    // We remove the old one (if exists) and add the new one
    _markers.removeWhere((m) => m.markerId == markerId);
    _markers.add(marker);
    
    notifyListeners();
  }
  
  @override
  void dispose() {
    _socketSubscription?.cancel();
    super.dispose();
  }
}
