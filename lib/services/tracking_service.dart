import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/unit_location_model.dart';
import '../models/api_config.dart';

/// Tracking service for real-time unit visualization.
/// Unified logic for fetching, filtering and polling.
class TrackingService {
  Timer? _pollingTimer;
  final _locationController = StreamController<List<UnitLocation>>.broadcast();

  Stream<List<UnitLocation>> get locationStream => _locationController.stream;

  bool _isInitialized = false;
  bool _streamClosed = false;
  String _currentRoute = '';

  /// Must be called once
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    print('🚀 TrackingService initialized');
  }

  /// Start tracking units for this specific route
  Future<void> fetchUnitsForRoute(String claveRuta) async {
    if (claveRuta.isEmpty) return;

    // Stop previous polling safely
    _pollingTimer?.cancel();

    _currentRoute = claveRuta;
    print('🚌 Tracking started for route: $_currentRoute');

    await _fetchAndFilterUnits();

    _startPolling();
  }

  /// Poll every 3 seconds
  void _startPolling() {
    _pollingTimer?.cancel();

    _pollingTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _fetchAndFilterUnits(),
    );
  }

  /// Core method — fetch units with route filtering
  Future<void> _fetchAndFilterUnits() async {
    if (_currentRoute.isEmpty || _streamClosed) return;

    // Debug logs
    print('\n🔄 POLLING UPDATE - ${DateTime.now().toIso8601String()}');
    print('📡 Buscando unidades para ruta: $_currentRoute');
    print('🔗 Parámetros enviados → clave_ruta=$_currentRoute, tipo_ruta=EXT');

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.unidadDeRuta}');

      final requestBody = {
        'empresa': ApiConfig.empresa,
        'idUsuario': ApiConfig.idUsuario,
        'tipo_usuario': ApiConfig.tipoUsuario,
        'clave_ruta': _currentRoute, // Correcto
        'tipo_ruta': 'EXT',          // Correcto
      };

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        print('⚠️ API error: ${response.statusCode}');
        return;
      }

      final json = jsonDecode(response.body);

      if (json['respuesta'] == true && json['data'] != null) {
        final List<dynamic> items = json['data'];

        final units =
            items.map((e) => UnitLocation.fromJson(e)).toList();

        print('📍 Found ${units.length} units for route $_currentRoute');

        if (!_streamClosed) _locationController.add(units);
      } else {
        print('⚠️ API responded but with no units');
        if (!_streamClosed) _locationController.add([]);
      }
    } catch (e) {
      print('⚠️ Error fetching units: $e');
    }
  }

  /// Cleanup
  void dispose() {
    _pollingTimer?.cancel();
    _streamClosed = true;

    if (!_locationController.isClosed) {
      _locationController.close();
    }

    print('🛑 TrackingService disposed');
  }
}
