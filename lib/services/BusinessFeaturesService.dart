import 'dart:convert';
import 'RequestServ.dart';

class BusinessFeaturesService {
  static Future<int> getBusinessFeatures(String dominioEmpresa) async {
    final serv = RequestServ.instance;
    try {
      final response = await serv.handlingRequest(
        urlParam: "api/business/$dominioEmpresa/features",
        method: 'GET',
      );

      if (response != null) {
        final trimmedResponse = response.trim();
        print("Features response: $trimmedResponse");
        
        // Try parsing directly as integer (fallback)
        final value = int.tryParse(trimmedResponse);
        if (value != null) {
          print("Parsed feature level (int): $value");
          return value;
        }
        
        // Try parsing as JSON
        try {
          final json = jsonDecode(trimmedResponse) as Map<String, dynamic>;
          if (json.containsKey('data') && json['data'] is Map) {
            final data = json['data'] as Map<String, dynamic>;
            final level = data['lectora'] ?? 1;
            print("Parsed feature level (from data.lectora): $level");
            return level;
          }
          // Fallback common keys
          final level = json['lectora'] ?? json['features'] ?? json['feature'] ?? json['level'] ?? 1;
          print("Parsed feature level (fallback keys): $level");
          return level;
        } catch (e) {
          print("Error parsing features JSON: $e");
        }
      }
      return 1; // Default a ACTIVA (QR) si hay error o no se encuentra
    } catch (e) {
      print("Error fetching business features: $e");
      return 1;
    }
  }
}
