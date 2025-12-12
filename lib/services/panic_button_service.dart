import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service to send panic button commands to Traccar
class PanicButtonService {
  static const String _baseUrl = 'http://rastreobusmen.geovoy.com:8082';
  static const String _username = 'usuariosapp';
  static const String _password = 'usuarios0904';

  /// Send panic button command to a specific device
  /// 
  /// [deviceId] is the idplataformagps of the unit
  Future<bool> sendPanicCommand(int deviceId) async {
    try {
      final url = Uri.parse('$_baseUrl/api/commands/send');
      
      // Create Basic Auth token
      final credentials = base64Encode(utf8.encode('$_username:$_password'));
      
      // Prepare payload
      final payload = {
        'id': 15,
        'deviceId': deviceId,
        'description': 'Regresar IO estatus',
        'type': 'custom',
        'attributes': {
          'data': 'readio #',
        },
      };
      
      print('🚨 Sending panic command to device $deviceId');
      
      // Make HTTP request
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      
      print('📡 Panic command response: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Panic command sent successfully');
        return true;
      } else {
        print('❌ Failed to send panic command: ${response.body}');
        return false;
      }
      
    } catch (e) {
      print('❌ Error sending panic command: $e');
      return false;
    }
  }
}
