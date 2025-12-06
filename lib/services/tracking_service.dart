import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/unit_location_model.dart';
import '../models/api_config.dart';

class UnityInfoResponse {
  final bool respuesta;
  final List<UnityInfoData> datos;

  UnityInfoResponse({required this.respuesta, required this.datos});

  factory UnityInfoResponse.fromJson(Map<String, dynamic> json) {
    return UnityInfoResponse(
      respuesta: json['respuesta'] ?? false,
      datos: (json['data'] as List<dynamic>?)
              ?.map((e) => UnityInfoData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class UnityInfoData {
  final String idplataformagps;

  UnityInfoData({required this.idplataformagps});

  factory UnityInfoData.fromJson(Map<String, dynamic> json) {
    return UnityInfoData(
      idplataformagps: json['idplataformagps']?.toString() ?? '',
    );
  }
}

/// Service for tracking units in real-time using API polling
/// Filters units by route-specific device IDs
class TrackingService {
  Timer? _pollingTimer;
  final _locationController = StreamController<List<UnitLocation>>.broadcast();
  
  Stream<List<UnitLocation>> get locationStream => _locationController.stream;
  
  bool _isInitialized = false;
  List<int> _allowedDeviceIds = []; // Device IDs for current route
  
  /// Initialize the tracking service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    print('🚀 Initializing TrackingService...');
    _isInitialized = true;
    print('✅ TrackingService initialized (ready for route-specific fetching)');
  }
  
  /// Fetch units for a specific route (two-step process)
  Future<void> fetchUnitsForRoute(String claveRuta) async {
    // Cancel any existing polling
    _pollingTimer?.cancel();
    
    // Paso 1: Obtener deviceIds para esta ruta
    print('📋 Step 1: Getting device IDs for route $claveRuta');
    _allowedDeviceIds = await _getDeviceIdsForRoute(ApiConfig.empresa, claveRuta);
    
    if (_allowedDeviceIds.isEmpty) {
      print('⚠️ No device IDs found for route $claveRuta');
      _locationController.add([]);
      // Even if empty, we might want to poll in case assignment changes? 
      // For now, we'll stop or maybe poll just in case. 
      // Let's continue polling but it will return empty until IDs appear.
    } else {
      print('✅ Will filter units by device IDs: $_allowedDeviceIds');
    }
    
    // Paso 2, 3, 4: Obtener y filtrar unidades inmediatamente
    await _fetchAndFilterUnits();
    
    // Start polling every 10 seconds
    _startPollingForRoute();
  }

  void _startPollingForRoute() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchAndFilterUnits();
    });
  }

  /// Obtener deviceIds por ruta
  Future<List<int>> _getDeviceIdsForRoute(String empresa, String routeClave) async {
    try {
      // Endpoint que devuelve la información de la unidad asignada a la ruta
      // Usamos unidadAsignadaRuta como se discutió
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.unidadAsignadaRutaEndpoint}');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'empresa': empresa,
          'idUsuario': ApiConfig.idUsuario,
          'tipo_ruta': ApiConfig.tipoRuta,
          'tipo_usuario': ApiConfig.tipoUsuario,
          'clave_ruta': routeClave,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print('📦 Raw Device IDs Response: ${response.body}'); // DEBUG
        final json = jsonDecode(response.body);
        final unityResponse = UnityInfoResponse.fromJson(json);
        
        if (unityResponse.respuesta) {
          final Set<int> ids = {};
          for (var item in unityResponse.datos) {
            final parsed = int.tryParse(item.idplataformagps);
            if (parsed != null) {
              ids.add(parsed);
            }
          }
          return ids.toList();
        }
      }
    } catch (e) {
      print('⚠️ Error fetching device IDs: $e');
    }
    return [];
  }
  
  /// Fetch all units and filter by allowed device IDs
  Future<void> _fetchAndFilterUnits() async {
    if (_allowedDeviceIds.isEmpty) return;

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.unidadDeRuta}');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'empresa': ApiConfig.empresa,
          // Nota: Enviamos clave_ruta aunque el backend no lo use para filtrar,
          // por si acaso en el futuro lo implementan.
          // Pero el filtrado real lo hacemos aquí.
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['respuesta'] == true && data['data'] != null) {
          final List<dynamic> unitsJson = data['data'];
          
          // Parse all units
          final allUnits = unitsJson
              .map((json) => UnitLocation.fromJson(json))
              .toList();
          
          // Paso 3: Filtrar unidades por deviceIds
          // El usuario indicó que UnitLocation.id debe coincidir con idplataformagps
          // Sin embargo, UnitLocation tiene idplataformagps explícito.
          // Usaremos idplataformagps para mayor seguridad.
          final filteredUnits = allUnits
              .where((unit) => _allowedDeviceIds.contains(unit.idplataformagps))
              .toList();
          
          // Paso 4: Emitir solo unidades filtradas
          _locationController.add(filteredUnits);
          print('📍 Showing ${filteredUnits.length} unit(s) (filtered from ${allUnits.length} total)');
        }
      }
    } catch (e) {
      print('⚠️ Error fetching units: $e');
    }
  }
  
  /// Dispose resources
  void dispose() {
    _pollingTimer?.cancel();
    _locationController.close();
    print('🛑 TrackingService disposed');
  }
}
