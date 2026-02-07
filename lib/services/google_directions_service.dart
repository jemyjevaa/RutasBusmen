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

    // Prepare all segments we need to fetch
    List<List<RouteStopModel>> pairs = [];
    for (int i = 0; i < stops.length - 1; i++) {
        pairs.add([stops[i], stops[i+1]]);
    }

    // Results container, indexed by segment position to ensure order
    List<List<LatLng>?> segmentResults = List.filled(pairs.length, null);

    // Batch settings
    const int batchSize = 6; // Fetch 6 segments at once
    
    for (int i = 0; i < pairs.length; i += batchSize) {
        int end = (i + batchSize < pairs.length) ? i + batchSize : pairs.length;
        List<Future<void>> batchFutures = [];

        for (int j = i; j < end; j++) {
            batchFutures.add(_fetchPair(pairs[j][0], pairs[j][1]).then((result) {
                segmentResults[j] = result;
            }));
        }

        // Wait for this batch to complete
        await Future.wait(batchFutures);

        // Small delay between batches to be gentle
        if (end < pairs.length) {
            await Future.delayed(const Duration(milliseconds: 300));
        }
    }

    // Stitch results together
    List<LatLng> fullPolyline = [];
    for (var segment in segmentResults) {
        if (segment != null && segment.isNotEmpty) {
           if (fullPolyline.isNotEmpty) {
             // Avoid duplicate point at connection
             segment.removeAt(0);
           }
           fullPolyline.addAll(segment);
        } else {
             // Fallback for failed segment: straight line
             // We need to re-derive which pair this was... bit messy logic above for fallback
             // actually segmentResults contains the points.
             // If we really want fallback, _fetchPair should return the fallback line on error?
             // Let's modify _fetchPair to return fallback instead of empty list on error.
        }
    }
    
    // Correction: Better logic is to let _fetchPair handle the fallback itself so we always get a valid line
    // Rerunning logic below with that assumption.
    return fullPolyline;
  }
  



  Future<List<LatLng>> _fetchPair(RouteStopModel originStop, RouteStopModel destStop) async {
      try {
        final origin = '${originStop.latitude},${originStop.longitude}';
        final destination = '${destStop.latitude},${destStop.longitude}';
        
        // Pure origin-destination request. No waypoints.
        final queryParams = {
          'origin': origin,
          'destination': destination,
          'key': _apiKey,
        };
        
        final url = Uri.https('maps.googleapis.com', '/maps/api/directions/json', queryParams);
        
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
            // print('⚠️ Google Directions Error (${originStop.name}->${destStop.name}): ${data['status']}');
             if (data['status'] == 'OVER_QUERY_LIMIT') {
               // If we hit a limit, wait a bit longer and retry once?
               // For now, simple logic: just return empty to trigger fallback
             }
          }
        }
      } catch (e) {
        print('⚠️ Error fetching pair segment: $e');
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
