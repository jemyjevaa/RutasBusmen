import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/route_viewmodel.dart';
import '../models/route_model.dart';

/// Widget reutilizable para seleccionar una ruta de las rutas disponibles
class RouteSelector extends StatelessWidget {
  final RouteData? selectedRoute;
  final Function(RouteData?) onRouteSelected;
  final Color primaryColor;

  const RouteSelector({
    super.key,
    required this.selectedRoute,
    required this.onRouteSelected,
    this.primaryColor = const Color(0xFFFF6B35),
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RouteViewModel>(
      builder: (context, viewModel, child) {
        return InkWell(
          onTap: () => _showRouteSelectionDialog(context, viewModel),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ruta seleccionada',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedRoute != null 
                            ? selectedRoute!.displayName
                            : 'Seleccionar ruta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: selectedRoute != null 
                              ? Colors.black87 
                              : Colors.grey[400],
                        ),
                      ),
                      if (selectedRoute != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          selectedRoute!.timeRange,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRouteSelectionDialog(BuildContext context, RouteViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.05),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Seleccionar Ruta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),

              // Lista de rutas
              if (viewModel.isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (viewModel.errorMessage != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          viewModel.errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (viewModel.allRoutes.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.route_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay rutas disponibles',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: viewModel.allRoutes.length,
                    itemBuilder: (context, index) {
                      final route = viewModel.allRoutes[index];
                      final isSelected = selectedRoute?.id == route.id;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? primaryColor.withOpacity(0.1) 
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? primaryColor 
                                : Colors.grey[200]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.directions_bus,
                              color: primaryColor,
                            ),
                          ),
                          title: Text(
                            route.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            route.timeRange,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: primaryColor)
                              : null,
                          onTap: () {
                            onRouteSelected(route);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
