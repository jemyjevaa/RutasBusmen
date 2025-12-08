import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

Widget buildSafeQRCode(String data) {
  try {
    if (data.isEmpty) {
      throw Exception("QR data vacío");
    }

    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: 200,
    );
  } catch (e) {
    print("Error al generar QR: $e");
    return Icon(
      Icons.eighteen_mp_outlined,
      size: 100,
      color: Colors.grey[300],
    );
  }
}
