import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/route_model.dart';
import '../models/route_stop_model.dart';
import '../models/api_config.dart';

/// Service for handling route API calls
class RouteApiService {
  
  Future<RouteResponse> fetchRoutes() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.unidadAsignadaRutaEndpoint}');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(ApiConfig.getRouteRequestBody()),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - Please check your internet connection');
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return RouteResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load routes: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || 
          e.toString().contains('HandshakeException')) {
        throw Exception('Network error - Please check your internet connection');
      }
      rethrow;
    }
  }

  /// Fetch route stops (points) from the API
  Future<RouteStopResponse> fetchRouteStops(String claveRuta) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.paradasRutaEndpoint}');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'empresa': ApiConfig.empresa,
          'clave_ruta': claveRuta,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - Please check your internet connection');
        },
      );

      if (response.statusCode == 200) {
        print('Route Stops Response Body: ${response.body}'); // DEBUG LOG
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return RouteStopResponse.fromJson(jsonData);
      } else {
        print('Failed to load route stops. Status: ${response.statusCode}'); // DEBUG LOG
        throw Exception('Failed to load route stops: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching route stops: $e');
      // Return empty response instead of throwing to avoid breaking the UI
      return RouteStopResponse(respuesta: false, data: []);
    }
  }

  /// Fetch unit assigned to a specific route
  Future<int?> fetchUnitForRoute(String claveRuta) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.unidadDeRuta}');
      print('🔍 Fetching unit for route: $claveRuta');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'empresa': ApiConfig.empresa,
          'clave_ruta': claveRuta,
        }),
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('📦 Unit response for $claveRuta: $data'); // DEBUG LOG
        if (data['respuesta'] == true && data['data'] != null) {
          // Assuming data contains deviceId or similar
          // Need to adjust based on actual response structure
          // For now, let's assume it returns a list and we take the first one
          final list = data['data'] as List;
          if (list.isNotEmpty) {
             return list[0]['id_unidad'] as int?; // Adjust key as needed
          }
        }
      }
    } catch (e) {
      print('Error fetching unit for route $claveRuta: $e');
    }
    return null;
  }

  /// Fetch device IDs (idplataformagps) assigned to a specific route
  /// This is used to filter which units should be displayed for a route
  Future<List<int>> fetchDeviceIdsForRoute(String claveRuta) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.unidadDeRuta}');
      print('🔍 Fetching device IDs for route: $claveRuta');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'empresa': ApiConfig.empresa,
          'clave_ruta': claveRuta,
        }),
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['respuesta'] == true && data['data'] != null) {
          final List<dynamic> units = data['data'];
          final Set<int> deviceIds = {};
          
          // Extract idplataformagps from each unit
          for (var unit in units) {
            if (unit['idplataformagps'] != null) {
              final id = unit['idplataformagps'];
              if (id is int) {
                deviceIds.add(id);
              } else if (id is String) {
                final parsed = int.tryParse(id);
                if (parsed != null) deviceIds.add(parsed);
              }
            }
          }
          
          print('✅ Found ${deviceIds.length} device ID(s) for route $claveRuta: $deviceIds');
          return deviceIds.toList();
        }
      }
    } catch (e) {
      print('⚠️ Error fetching device IDs for route $claveRuta: $e');
    }
    return [];
  }
  /// Fetch route path (waypoints) from the API
  Future<List<Map<String, dynamic>>> fetchRoutePath(String claveRuta) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.infoRutaEndpoint}');
      print('🔍 Fetching route path for: $claveRuta');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'empresa': ApiConfig.empresa,
          'clave_ruta': claveRuta,
        }),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        // print('Route Path Response: ${response.body}'); // DEBUG
        final data = jsonDecode(response.body);
        if (data['respuesta'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (e) {
      print('⚠️ Error fetching route path: $e');
    }
    return [];
  }
}
