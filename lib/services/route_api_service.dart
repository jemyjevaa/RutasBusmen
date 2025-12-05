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
}
