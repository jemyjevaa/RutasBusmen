import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

Widget buildSafeBarcode(String data) {
  try {
    if (data.isEmpty) {
      throw Exception("Barcode data vacío");
    }

    return BarcodeWidget(
      barcode: Barcode.code128(), // Usamos Code128 como estándar
      data: data,
      width: 280,
      height: 100,
      drawText: true,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    );
  } catch (e) {
    print("Error al generar Barcode: $e");
    return Icon(
      Icons.barcode_reader,
      size: 100,
      color: Colors.grey[300],
    );
  }
}
