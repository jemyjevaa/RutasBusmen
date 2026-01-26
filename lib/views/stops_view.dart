import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/route_selector.dart';
import '../models/route_model.dart';
import '../models/route_stop_model.dart'; // Import RouteStopModel
import '../viewmodels/route_viewmodel.dart'; // Import RouteViewModel

class StopsView extends StatefulWidget {
  final RouteData? initialRoute;
  
  const StopsView({super.key, this.initialRoute});

  @override
  State<StopsView> createState() => _StopsViewState();
}

class _StopsViewState extends State<StopsView> {
  static const Color primaryOrange = Color(0xFFFF6B35);
  
  // Ruta seleccionada
  RouteData? _selectedRoute;

  @override
  void initState() {
    super.initState();
    // Fetch routes if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<RouteViewModel>();
      if (viewModel.allRoutes.isEmpty) {
        viewModel.fetchRoutes();
      }
      
      // If initialRoute is provided, set it and fetch stops
      if (widget.initialRoute != null) {
        setState(() {
          _selectedRoute = widget.initialRoute;
        });
        viewModel.fetchStopsForRoute(widget.initialRoute!.claveRuta);
      }
    });
  }

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
          // Route Selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer<RouteViewModel>(
              builder: (context, viewModel, child) {
                return RouteSelector(
                  selectedRoute: _selectedRoute,
                  onRouteSelected: (route) {
                    setState(() {
                      _selectedRoute = route;
                    });
                    // Fetch stops for the selected route
                    if (route != null) {
                      viewModel.fetchStopsForRoute(route.claveRuta);
                    } else {
                      viewModel.clearRouteStops();
                    }
                  },
                  primaryColor: primaryOrange,
                );
              },
            ),
          ),

          // Header con información de la ruta (solo si hay ruta seleccionada)
          if (_selectedRoute != null)
             Consumer<RouteViewModel>(
              builder: (context, viewModel, child) {
                return Container(
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
                            Text(
                              'Ruta: ${_selectedRoute!.nombreRuta}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Show number of stops if loaded
                            Text(
                              viewModel.isLoadingStops 
                                  ? 'Cargando paradas...' 
                                  : '${viewModel.routeStops.length} paradas',
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
                );
              }
             ),

          // Lista de paradas
          Expanded(
            child: Consumer<RouteViewModel>(
              builder: (context, viewModel, child) {
                if (_selectedRoute == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.route,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Selecciona una ruta para ver las paradas',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (viewModel.isLoadingStops) {
                   return const Center(
                     child: CircularProgressIndicator(color: primaryOrange),
                   );
                }

                if (viewModel.routeStops.isEmpty) {
                   return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.highlight_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay paradas disponibles para esta ruta',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: viewModel.routeStops.length,
                    itemBuilder: (context, index) {
                      return _buildStopItem(viewModel.routeStops[index], index, viewModel.routeStops.length);
                    },
                  );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopItem(RouteStopModel stop, int index, int total) {
    // Basic implementation without "isPassed" logic as we don't have unit location here contextually relevant to user trip in this view
    final bool isLast = index == total - 1;

    // Use "description" if available, otherwise fallback or empty
    final String address = stop.description ?? 'Ubicación de parada';

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
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryOrange,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
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
                height: 80, // Adjustable height based on content
                color: primaryOrange.withOpacity(0.3),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
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
                        stop.name ?? 'Parada ${index + 1}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    // Removed Time Container here
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
                        address,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
