import 'package:flutter/material.dart';

class StopsView extends StatefulWidget {
  const StopsView({super.key});

  @override
  State<StopsView> createState() => _StopsViewState();
}

class _StopsViewState extends State<StopsView> {
  static const Color primaryOrange = Color(0xFFFF6B35);

  // Datos de ejemplo de paradas
  final List<Map<String, dynamic>> _stops = [
    {
      'name': 'CUARTA GLORIETA',
      'time': '08:00 AM',
      'address': 'Av. Principal #123',
      'isPassed': true,
    },
    {
      'name': 'AV. SAN RAFAEL',
      'time': '08:15 AM',
      'address': 'Blvd. Comercio #456',
      'isPassed': true,
    },
    {
      'name': 'AV. SAN GABRIEL',
      'time': '08:30 AM',
      'address': 'Av. Educación #789',
      'isPassed': false,
      'isNext': true,
    },
    {
      'name': 'TERCERA GLORIETA',
      'time': '08:45 AM',
      'address': 'Calle Salud #321',
      'isPassed': false,
    },
    {
      'name': 'SEGUNDA GLORIETA',
      'time': '09:00 AM',
      'address': 'Av. Verde #654',
      'isPassed': false,
    },
    {
      'name': 'SAN PEDRO',
      'time': '09:15 AM',
      'address': 'Carretera Norte Km 5',
      'isPassed': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paradas'),
        backgroundColor: primaryOrange,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          // Header con información de la ruta
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryOrange.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: primaryOrange.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryOrange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.directions_bus,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ruta: LA VIRGEN',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '6 paradas • 1h 15min',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Lista de paradas
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _stops.length,
              itemBuilder: (context, index) {
                return _buildStopItem(_stops[index], index, _stops.length);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopItem(Map<String, dynamic> stop, int index, int total) {
    final bool isPassed = stop['isPassed'] ?? false;
    final bool isNext = stop['isNext'] ?? false;
    final bool isLast = index == total - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline vertical
        Column(
          children: [
            // Círculo indicador
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isPassed
                    ? primaryOrange
                    : isNext
                        ? primaryOrange
                        : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryOrange,
                  width: isPassed || isNext ? 3 : 2,
                ),
                boxShadow: isNext
                    ? [
                        BoxShadow(
                          color: primaryOrange.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: isPassed
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      )
                    : isNext
                        ? const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 20,
                          )
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: primaryOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
              ),
            ),
            // Línea conectora
            if (!isLast)
              Container(
                width: 3,
                height: 80,
                color: isPassed
                    ? primaryOrange
                    : primaryOrange.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Información de la parada
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isNext
                  ? primaryOrange.withOpacity(0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isNext
                    ? primaryOrange
                    : Colors.grey[300]!,
                width: isNext ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        stop['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isPassed
                              ? Colors.grey[600]
                              : Colors.black87,
                          decoration: isPassed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isNext
                            ? primaryOrange
                            : isPassed
                                ? Colors.grey[300]
                                : primaryOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        stop['time'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isNext
                              ? Colors.white
                              : isPassed
                                  ? Colors.grey[600]
                                  : primaryOrange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        stop['address'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                if (isNext) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: primaryOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: primaryOrange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Próxima parada',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
