import 'package:flutter/cupertino.dart';

Widget buildImage(String? url) {
  // 1. Si viene nula o vacía → usar asset por defecto
  if (url == null || url.trim().isEmpty) {
    return Image.asset(
      'assets/images/logos/LogoBusmen.png',
      width: 180,
      height: 80,
      fit: BoxFit.contain,
    );
  }

  // 2. Si empieza con http/https → es una URL remota
  if (url.startsWith('http')) {
    return Image.network(
      url.replaceAll(RegExp(r"\s+"), "%20"),
      width: 180,
      height: 80,
      fit: BoxFit.contain,
      // 3. Si falla la carga → también usar asset por defecto
      errorBuilder: (context, error, stack) {
        return Image.asset(
          'assets/images/logos/LogoBusmen.png',
          width: 180,
          height: 80,
          fit: BoxFit.contain,
        );
      },
    );
  }

  // 4. Si no es URL → se asume que es un asset local
  return Image.asset(
    url,
    width: 180,
    height: 80,
    fit: BoxFit.contain,
  );
}