import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/route_stop_model.dart';

class GoogleDirectionsService {
  // Using the key found in AndroidManifest.xml
  static const String _apiKey = 'AIzaSyA6WSHJ8R0AMDhhk0e_-Sn0KLEwSB60QKw';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';

  Future<List<LatLng>> getRoutePolyline(List<RouteStopModel> stops) async {
    if (stops.length < 2) return [];

    try {
      final origin = '${stops.first.latitude},${stops.first.longitude}';
      final destination = '${stops.last.latitude},${stops.last.longitude}';
      
      String waypoints = '';
      if (stops.length > 2) {
        final intermediate = stops.sublist(1, stops.length - 1);
        final waypointsList = intermediate
            .map((s) => 'via:${s.latitude},${s.longitude}')
            .toList();
        
        if (waypointsList.isNotEmpty) {
          waypoints = waypointsList.join('|');
        }
      }

      final queryParams = {
        'origin': origin,
        'destination': destination,
        'key': _apiKey,
      };
      
      if (waypoints.isNotEmpty) {
        queryParams['waypoints'] = waypoints;
      }

      final url = Uri.https('maps.googleapis.com', '/maps/api/directions/json', queryParams);
      print('🗺️ Requesting Google Directions: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'OK') {
          final routes = data['routes'] as List;
          if (routes.isNotEmpty) {
            final points = routes[0]['overview_polyline']['points'];
            return _decodePolyline(points);
          }
        } else {
          print('⚠️ Google Directions Error: ${data['status']} - ${data['error_message']}');
        }
      } else {
        print('⚠️ Google Directions HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Error fetching Google Directions: $e');
    }
    
    return [];
  }

  /// Decodes encoded polyline string from Google Directions API
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      final p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }
}
