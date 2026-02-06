import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Added for Icons and Colors

import '../../viewmodels/route_viewmodel.dart';

Widget timeUnitToUser(RouteViewModel vm){
  bool isTime = vm.isUnitInRoute && vm.currentDestination.isNotEmpty;
  
  if (!isTime) return const SizedBox.shrink();

  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.timer_outlined, color: Color(0xFFFF9800), size: 28),
            const SizedBox(width: 8),
            Text(
              "${vm.timeUnitUser} ",
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFF9800),
                height: 1.0,
              ),
            ),
            const Text(
              "minutos",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF9800),
                height: 1.5,
              ),
            ),
          ],
        ),
        Text(
          "Tiempo estimado de llegada de la unidad a tu ubicación",
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),

        Text(
          "Unidad:",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          vm.nameUnit,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}