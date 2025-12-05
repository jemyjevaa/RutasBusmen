class ServerResponse {
  final String respuesta;
  final List<ServerData> datos;

  ServerResponse({
    required this.respuesta,
    required this.datos,
  });

  factory ServerResponse.fromJson(Map<String, dynamic> json) {
    return ServerResponse(
      respuesta: json['respuesta']?.toString() ?? '',
      datos: (json['datos'] as List?)
              ?.map((e) => ServerData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ServerData {
  final String id;
  final String nombre;
  final String url;
  final String clave;
  final String estatus;

  ServerData({
    required this.id,
    required this.nombre,
    required this.url,
    required this.clave,
    required this.estatus,
  });

  factory ServerData.fromJson(Map<String, dynamic> json) {
    return ServerData(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      clave: json['clave']?.toString() ?? '',
      estatus: json['estatus']?.toString() ?? '',
    );
  }
}
