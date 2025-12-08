// region Login
class ApiResLogin {
  final bool respuesta;
  final Usuario usuario;
  final Empresa empresa;

  ApiResLogin({
    required this.respuesta,
    required this.usuario,
    required this.empresa,
  });

  factory ApiResLogin.fromJson(Map<String, dynamic> json) {
    return ApiResLogin(
      respuesta: json['respuesta'] ?? false,
      usuario: Usuario.fromJson(json['usuario']),
      empresa: Empresa.fromJson(json['empresa']),
    );
  }
}

class Usuario {
  final int id;
  final int idCli;
  final String nombre;
  final String ruta1;
  final String ruta2;
  final String ruta3;
  final String ruta4;
  final String horario;
  final String claveParada;
  final String paradaAscenso;
  final String email;
  final String tipoUsuario;
  final int estatus;
  final int sesion;
  final String usuario;

  Usuario({
    required this.id,
    required this.idCli,
    required this.nombre,
    required this.ruta1,
    required this.ruta2,
    required this.ruta3,
    required this.ruta4,
    required this.horario,
    required this.claveParada,
    required this.paradaAscenso,
    required this.email,
    required this.tipoUsuario,
    required this.estatus,
    required this.sesion,
    required this.usuario,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? 0,
      idCli: json['id_cli'] ?? 0,
      nombre: json['nombre'] ?? '',
      ruta1: json['ruta1'] ?? '',
      ruta2: json['ruta2'] ?? '',
      ruta3: json['ruta3'] ?? '',
      ruta4: json['ruta4'] ?? '',
      horario: json['horario'] ?? '',
      claveParada: json['clave_parada'] ?? '',
      paradaAscenso: json['parada_ascenso'] ?? '',
      email: json['email'] ?? '',
      tipoUsuario: json['tipo_usuario'] ?? '',
      estatus: json['estatus'] ?? 0,
      sesion: json['sesion'] ?? 0,
      usuario: json['usuario'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "id_cli": idCli,
    "nombre": nombre,
    "ruta1": ruta1,
    "ruta2": ruta2,
    "ruta3": ruta3,
    "ruta4": ruta4,
    "horario": horario,
    "clave_parada": claveParada,
    "parada_ascenso": paradaAscenso,
    "email": email,
    "tipo_usuario": tipoUsuario,
    "estatus": estatus,
    "sesion": sesion,
    "usuario": usuario,
  };

}

class Empresa {
  final int id;
  final String nombre;
  final String clave;
  final String correos;
  final String telefonos;
  final String latitudLongitud;
  final String color1;
  final String color2;
  final String colorletra;
  final int webapi;
  final int proyecto;
  final int geocerca;
  final String notificacionId;
  final String notificacionKey;
  final int estatus;
  final String imagen;
  final String usuarioAlta;
  final int turno;

  Empresa({
    required this.id,
    required this.nombre,
    required this.clave,
    required this.correos,
    required this.telefonos,
    required this.latitudLongitud,
    required this.color1,
    required this.color2,
    required this.colorletra,
    required this.webapi,
    required this.proyecto,
    required this.geocerca,
    required this.notificacionId,
    required this.notificacionKey,
    required this.estatus,
    required this.imagen,
    required this.usuarioAlta,
    required this.turno,
  });

  factory Empresa.fromJson(Map<String, dynamic> json) {
    return Empresa(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      clave: json['clave'] ?? '',
      correos: json['correos'] ?? '',
      telefonos: json['telefonos'] ?? '',
      latitudLongitud: json['latitud_longitud'] ?? '',
      color1: json['color1'] ?? '',
      color2: json['color2'] ?? '',
      colorletra: json['colorletra'] ?? '',
      webapi: json['webapi'] ?? 0,
      proyecto: json['proyecto'] ?? 0,
      geocerca: json['geocerca'] ?? 0,
      notificacionId: json['notificacion_id'] ?? '',
      notificacionKey: json['notificacion_key'] ?? '',
      estatus: json['estatus'] ?? 0,
      imagen: json['imagen'] ?? '',
      usuarioAlta: json['usuario_alta'] ?? '',
      turno: json['turno'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() =>{
    "id":id,
    "nombre":nombre,
    "clave":clave,
    "correos":correos,
    "telefonos":telefonos,
    "latitud_longitud":latitudLongitud,
    "color1":color1,
    "color2":color2,
    "colorletra":colorletra,
    "webapi":webapi,
    "proyecto":proyecto,
    "geocerca":geocerca,
    "notificacion_id":notificacionId,
    "notificacion_key":notificacionKey,
    "estatus":estatus,
    "imagen":imagen,
    "usuario_alta":usuarioAlta,
    "turno":turno,
  };

}

// endregion Login

// region notification
class ApiResNotification {
  final bool respuesta;
  final List<NotificationItem> data;

  ApiResNotification({
    required this.respuesta,
    required this.data,
  });

  // Si tu API te devuelve un JSON, puedes usar un factory constructor:
  factory ApiResNotification.fromJson(Map<String, dynamic> json) {
    return ApiResNotification(
      respuesta: json['respuesta'] as bool,
      data: List<NotificationItem>.from(json['data'] as List<dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'respuesta': respuesta,
      'data': data,
    };
  }
}
class NotificationItem {
  final String title;
  final String message;
  final String time;
  final String id;  // o lo que identifique
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      time: json['time'] as String,
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}
// endregion notification