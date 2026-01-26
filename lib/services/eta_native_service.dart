import 'dart:io';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for managing native ETA display on iOS (Live Activities) and Android (Foreground Service)
/// This service acts as a bridge between Flutter and native platform code
class ETANativeService {
  static const _iosChannel = MethodChannel('com.geovoy.geovoy_app/eta_live_activity');
  static const _androidChannel = MethodChannel('com.geovoy.geovoy_app/eta_foreground_service');
  
  bool _isActive = false;
  String? _currentTripId;
  int? _lastETA;
  
  bool get isActive => _isActive;
  
  /// Start native ETA display
  /// [tripId] - Unique identifier for the trip
  /// [routeName] - Name of the route being tracked
  /// [eta] - Estimated time in minutes
  /// [status] - Current status text (e.g., "En camino")
  Future<void> startETADisplay({
    required String tripId,
    required String routeName,
    required int eta,
    required String status,
  }) async {
    if (_isActive && _currentTripId == tripId) {
      // Already active for this trip, just update
      await updateETA(eta: eta, status: status);
      return;
    }
    
    // Stop any existing display first
    if (_isActive) {
      await stopETADisplay();
    }
    
    try {
      if (Platform.isIOS) {
        await _iosChannel.invokeMethod('startLiveActivity', {
          'tripId': tripId,
          'routeName': routeName,
          'eta': eta,
          'status': status,
        });
        print('🍎 Live Activity started for trip: $tripId');
      } else if (Platform.isAndroid) {
        // Permissions are now handled explicitly via tutorial or settings toggle
        await _androidChannel.invokeMethod('startService', {
          'tripId': tripId,
          'routeName': routeName,
          'eta': eta,
          'status': status,
        });
        print('🤖 Foreground Service started for trip: $tripId');
      }
      
      _isActive = true;
      _currentTripId = tripId;
      _lastETA = eta;
    } catch (e) {
      print('❌ Error starting native ETA display: $e');
      _isActive = false;
      _currentTripId = null;
    }
  }
  
  /// Update ETA value and status
  /// Only sends update if ETA has actually changed to avoid unnecessary native calls
  Future<void> updateETA({
    required int eta,
    required String status,
  }) async {
    if (!_isActive) {
      print('⚠️ Cannot update ETA: display not active');
      return;
    }
    
    // Only update if ETA has changed
    if (_lastETA == eta) {
      return;
    }
    
    try {
      if (Platform.isIOS) {
        await _iosChannel.invokeMethod('updateLiveActivity', {
          'eta': eta,
          'status': status,
        });
        print('🍎 Live Activity updated: ETA=$eta min');
      } else if (Platform.isAndroid) {
        await _androidChannel.invokeMethod('updateService', {
          'eta': eta,
          'status': status,
        });
        print('🤖 Foreground Service updated: ETA=$eta min');
      }
      
      _lastETA = eta;
    } catch (e) {
      print('❌ Error updating ETA: $e');
    }
  }
  
  /// Stop native ETA display
  Future<void> stopETADisplay() async {
    if (!_isActive) {
      return;
    }
    
    try {
      if (Platform.isIOS) {
        await _iosChannel.invokeMethod('endLiveActivity');
        print('🍎 Live Activity ended');
      } else if (Platform.isAndroid) {
        await _androidChannel.invokeMethod('stopService');
        print('🤖 Foreground Service stopped');
      }
    } catch (e) {
      print('❌ Error stopping native ETA display: $e');
    } finally {
      _isActive = false;
      _currentTripId = null;
      _lastETA = null;
    }
  }
  
  /// Force update even if ETA hasn't changed (useful for status changes)
  Future<void> forceUpdate({
    required int eta,
    required String status,
  }) async {
    _lastETA = null; // Reset to force update
    await updateETA(eta: eta, status: status);
  }

  /// Request System Alert Window permission for Android
  Future<void> requestOverlayPermission() async {
    if (Platform.isAndroid) {
      await Permission.notification.request();
      await Permission.systemAlertWindow.request();
    }
  }

  /// Check if required Android permissions are granted
  Future<bool> checkAndroidPermissions() async {
    if (!Platform.isAndroid) return true;
    
    final statusOverlay = await Permission.systemAlertWindow.status;
    final statusNotification = await Permission.notification.status;
    
    // For Android 13+, we need both. For older versions, overlay is priority.
    return statusOverlay.isGranted && statusNotification.isGranted;
  }
}
