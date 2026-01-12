import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/route_model.dart';
import '../models/route_stop_model.dart';
import '../models/unit_location_model.dart';
import '../models/api_config.dart';

/// Simplified service for handling route API calls
class RouteApiService {
  
  // Simple method to get units with live positions
  Future<List<UnitLocation>> getUnitsForRoute(String empresa, String claveRuta) async {
    try {
      // print('🔍 Fetching units for route: $claveRuta, empresa: $empresa');
      
      // Get unit assignments
      final url = Uri.parse('${ApiConfig.baseUrl}/unidadDeRuta');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'empresa': empresa,
          'claveRuta': claveRuta, // Changed back to claveRuta to match Swift logs
        }),
      ).timeout(const Duration(seconds: 30));

      // print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['respuesta'] == true && data['data'] != null) {
          final units = <UnitLocation>[];
          final unitsList = data['data'] as List;
          
          for (var unitData in unitsList) {
            // Swift app flow: unidadDeRuta -> then fetch device/position details
            // For now, we'll create the unit with available data and enrich it later
            // or use the coordinates if present (as fallback)
            
            final lat = unitData['latitude'];
            final lng = unitData['longitude'];
            
            final unit = UnitLocation(
              id: unitData['id'] ?? 0,
              clave: unitData['clave'] ?? '',
              idplataformagps: int.tryParse(unitData['idplataformagps']?.toString() ?? '0') ?? 0,
              positionId: unitData['positionId'] ?? 0,
              category: unitData['category'] ?? 'bus',
              latitude: (lat is double) ? lat : double.tryParse(lat.toString() ?? '0') ?? 0.0,
              longitude: (lng is double) ? lng : double.tryParse(lng.toString() ?? '0') ?? 0.0,
              speed: 0.0,
              course: 0.0,
              destination: null,
              isInRoute: true,
            );
            units.add(unit);
          }
          return units;
        }
      }
    } catch (e) {
      print('❌ Error getting units: $e');
    }
    return [];
  }

  /// Fetch device details from Traccar API (matches Swift 'devices' call)
  Future<Map<String, dynamic>?> getDeviceDetails(int deviceId) async {
    try {
      final url = Uri.parse('https://rastreobusmen.geovoy.com/api/devices?id=$deviceId');
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Basic dXN1YXJpb3NhcHA6dXN1YXJpb3MwOTA0', // From Swift logs
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return data.first as Map<String, dynamic>;
        }
      }
    } catch (e) {
      print('❌ Error getting device details: $e');
    }
    return null;
  }

  /// Fetch position details from Traccar API (matches Swift 'positions' call)
  Future<Map<String, dynamic>?> getDevicePosition(int positionId) async {
    try {
      final url = Uri.parse('https://rastreobusmen.geovoy.com/api/positions?id=$positionId');
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Basic dXN1YXJpb3NhcHA6dXN1YXJpb3MwOTA0', // From Swift logs
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return data.first as Map<String, dynamic>;
        }
      }
    } catch (e) {
      print('❌ Error getting position details: $e');
    }
    return null;
  }

  // Fetch live position from GPS API
  Future<Map<String, dynamic>?> _fetchPosition(int positionId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/positions?id=$positionId');
      final basicAuth = 'Basic ${base64Encode(utf8.encode('${ApiConfig.gpsUsername}:${ApiConfig.gpsPassword}'))}';
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': basicAuth,
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          return data[0] as Map<String, dynamic>;
        }
      }
    } catch (e) {
      print('⚠️ Error fetching position $positionId: $e');
    }
    return null;
  }

  // Simple method to get stops
  Future<List<RouteStopModel>> getStopsForRoute(String empresa, String claveRuta) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/paradasRuta');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'empresa': empresa,
          'clave_ruta': claveRuta,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['respuesta'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((e) => RouteStopModel.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      print('❌ Error getting stops: $e');
    }
    return [];
  }

  // Keep existing methods for compatibility
  Future<RouteResponse> fetchRoutes() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.unidadAsignadaRutaEndpoint}');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(ApiConfig.getRouteRequestBody()),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return RouteResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load routes: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<RouteStopResponse> fetchRouteStops(String claveRuta) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.paradasRutaEndpoint}');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'empresa': ApiConfig.empresa,
          'clave_ruta': claveRuta,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return RouteStopResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load route stops: ${response.statusCode}');
      }
    } catch (e) {
      return RouteStopResponse(respuesta: false, data: []);
    }
  }

  /// Fetch device IDs (idplataformagps) assigned to a specific route
  /// This is used to filter which units should be displayed for a route
  Future<List<int>> fetchDeviceIdsForRoute(String claveRuta) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.unidadDeRuta}');
      // print('🔍 Fetching device IDs for route: $claveRuta');
      
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
          
          // print('✅ Found ${deviceIds.length} device ID(s) for route $claveRuta: $deviceIds');
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

  /// Fetch device details (Traccar API)
  /// Replicates Swift: serviceDevice(idUnidad)
  Future<Map<String, dynamic>?> fetchDevice(int idPlataformaGps) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.devicesEndpoint}?id=$idPlataformaGps');
      final basicAuth = 'Basic ${base64Encode(utf8.encode('${ApiConfig.gpsUsername}:${ApiConfig.gpsPassword}'))}';
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': basicAuth,
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          return data[0] as Map<String, dynamic>;
        }
      } else {
        print('⚠️ Failed to fetch device $idPlataformaGps: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Error fetching device $idPlataformaGps: $e');
    }
    return null;
  }

  /// Fetch position details (Traccar API)
  /// Replicates Swift: servicePosition(idUnidad) -> actually uses positionId
  Future<Map<String, dynamic>?> fetchPosition(int positionId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.positionsEndpoint}?id=$positionId');
      final basicAuth = 'Basic ${base64Encode(utf8.encode('${ApiConfig.gpsUsername}:${ApiConfig.gpsPassword}'))}';
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': basicAuth,
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          return data[0] as Map<String, dynamic>;
        }
      } else {
        print('⚠️ Failed to fetch position $positionId: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Error fetching position $positionId: $e');
    }
    return null;
  }
}
