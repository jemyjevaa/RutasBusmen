class ValidateDomainResponse {
  final String respuesta;
  final List<DomainData> datos;

  ValidateDomainResponse({
    required this.respuesta,
    required this.datos,
  });

  factory ValidateDomainResponse.fromJson(Map<String, dynamic> json) {
    return ValidateDomainResponse(
      respuesta: json['respuesta']?.toString() ?? '',
      datos: (json['datos'] as List<dynamic>?)
              ?.map((e) => DomainData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class DomainData {
  final String id;
  final String nombre;

  DomainData({
    required this.id,
    required this.nombre,
  });

  factory DomainData.fromJson(Map<String, dynamic> json) {
    return DomainData(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
    );
  }
}

class ValidateCompanyResponse {
  final String respuesta;
  final List<CompanyData> datos;

  ValidateCompanyResponse({
    required this.respuesta,
    required this.datos,
  });

  factory ValidateCompanyResponse.fromJson(Map<String, dynamic> json) {
    return ValidateCompanyResponse(
      respuesta: json['respuesta']?.toString() ?? '',
      datos: (json['datos'] as List<dynamic>?)
              ?.map((e) => CompanyData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CompanyData {
  final String id;
  final String nombre;
  final String? logo;

  CompanyData({
    required this.id,
    required this.nombre,
    this.logo,
  });

  factory CompanyData.fromJson(Map<String, dynamic> json) {
    return CompanyData(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      logo: json['logo']?.toString(),
    );
  }
}

class ValidateUserResponse {
  final String respuesta;
  final List<UserData> datos;

  ValidateUserResponse({
    required this.respuesta,
    required this.datos,
  });

  factory ValidateUserResponse.fromJson(Map<String, dynamic> json) {
    return ValidateUserResponse(
      respuesta: json['respuesta']?.toString() ?? '',
      datos: (json['datos'] as List<dynamic>?)
              ?.map((e) => UserData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  bool get isSuccess => respuesta.isNotEmpty && datos.isNotEmpty;
}

class UserData {
  final String id;
  final String nombre;
  final String email;
  final String idEmpresa;
  final String? telefono;

  UserData({
    required this.id,
    required this.nombre,
    required this.email,
    required this.idEmpresa,
    this.telefono,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      idEmpresa: json['idempresa']?.toString() ?? json['idEmpresa']?.toString() ?? '',
      telefono: json['telefono']?.toString(),
    );
  }
}
