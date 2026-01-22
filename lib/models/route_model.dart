/// Route models based on API response structure
/// Converted from Swift ItemRutas model

import 'package:flutter/material.dart';

/// Main response wrapper
class RouteResponse {
  final bool respuesta;
  final List<RouteData> data;

  RouteResponse({
    required this.respuesta,
    required this.data,
  });

  factory RouteResponse.fromJson(Map<String, dynamic> json) {
    return RouteResponse(
      respuesta: json['respuesta'] as bool? ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => RouteData.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'respuesta': respuesta,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

/// Individual route data
class RouteData {
  final int id;
  final String nombreRuta;
  final String turnoRuta;
  final String direccionRuta;
  final String claveRuta;
  final List<String> diaRuta;
  final String horaInicioRuta;
  final String horaFinRuta;
  final String tipoRuta;

  RouteData({
    required this.id,
    required this.nombreRuta,
    required this.turnoRuta,
    required this.direccionRuta,
    required this.claveRuta,
    required this.diaRuta,
    required this.horaInicioRuta,
    required this.horaFinRuta,
    required this.tipoRuta,
  });

  factory RouteData.fromJson(Map<String, dynamic> json) {
    return RouteData(
      id: (json['id'] is int) ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nombreRuta: json['nombre_ruta']?.toString() ?? '',
      turnoRuta: json['turno_ruta']?.toString() ?? '',
      direccionRuta: json['direccion_ruta']?.toString() ?? '',
      claveRuta: json['clave_ruta']?.toString() ?? '',
      diaRuta: (json['dia_ruta'] as List<dynamic>?)
          ?.map((item) => item?.toString() ?? '')
          .toList() ?? [],
      horaInicioRuta: json['hora_inicio_ruta']?.toString() ?? '',
      horaFinRuta: json['hora_fin_ruta']?.toString() ?? '',
      tipoRuta: json['tipo_ruta']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_ruta': nombreRuta,
      'turno_ruta': turnoRuta,
      'direccion_ruta': direccionRuta,
      'clave_ruta': claveRuta,
      'dia_ruta': diaRuta,
      'hora_inicio_ruta': horaInicioRuta,
      'hora_fin_ruta': horaFinRuta,
      'tipo_ruta': tipoRuta,
    };
  }

  /// Check if route is currently active based on time
  bool isActiveNow() {
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    // print('⏰ Schedule check: Current=$currentTime, Start=$horaInicioRuta, End=$horaFinRuta');
    
    // Parse times for proper comparison
    try {
      final current = TimeOfDay(hour: now.hour, minute: now.minute);
      final start = _parseTime(horaInicioRuta);
      final end = _parseTime(horaFinRuta);
      
      final currentMinutes = current.hour * 60 + current.minute;
      final startMinutes = start.hour * 60 + start.minute;
      final endMinutes = end.hour * 60 + end.minute;
      
      final isActive = currentMinutes >= startMinutes && currentMinutes <= endMinutes;
      // print('⏰ Is active: $isActive (current: $currentMinutes, start: $startMinutes, end: $endMinutes)');
      
      return isActive;
    } catch (e) {
      print('❌ Error parsing time: $e');
      // If parsing fails, assume route is active
      return true;
    }
  }
  
  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  /// Get display name with direction
  String get displayName {
    return '$nombreRuta - $direccionRuta';
  }

  /// Get time range display
  String get timeRange {
    return '$horaInicioRuta - $horaFinRuta';
  }
}
