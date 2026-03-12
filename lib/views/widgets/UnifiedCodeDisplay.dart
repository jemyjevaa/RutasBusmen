import 'package:flutter/material.dart';
import '../../services/UserSession.dart';
import 'BuildQrProfileWidget.dart';
import 'BuildBarcodeWidget.dart';

class UnifiedCodeDisplay extends StatelessWidget {
  final String data;
  final String label;

  const UnifiedCodeDisplay({
    Key? key,
    required this.data,
    this.label = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final session = UserSession();
    final featureLevel = session.featureLevel;
    final isExpired = session.isQRExpired();

    if (isExpired) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
            SizedBox(height: 8),
            Text(
              "Código Expirado",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            Text(
              "Por favor, inicie sesión nuevamente para renovar.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
        ],
        _buildCodes(featureLevel),
      ],
    );
  }

  Widget _buildCodes(int level) {
    switch (level) {
      case 2: // SOLO COD BARRAS
        return buildSafeBarcode(data);
      case 3: // SOLO COD QR
        return buildSafeQRCode(data);
      case 4: // AMBAS
        return Column(
          children: [
            buildSafeQRCode(data),
            const SizedBox(height: 20),
            buildSafeBarcode(data),
          ],
        );
      case 1: // ACTIVA (No mostrar nada)
      default:
        return const SizedBox.shrink();
    }
  }
}
