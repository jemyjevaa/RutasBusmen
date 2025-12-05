import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'notifications_view.dart';
import 'profile_view.dart';
import 'stops_view.dart';
import 'lost_objects_view.dart';
import 'assistance_chat_view.dart';
import 'suggestions_view.dart';
import 'survey_view.dart';
import 'login_screen.dart';
import '../utils/app_strings.dart';
import '../viewmodels/route_viewmodel.dart';
import '../models/route_model.dart';
import '../models/route_stop_model.dart';

class MapsView extends StatefulWidget {
  const MapsView({super.key});

  @override
  State<MapsView> createState() => _MapsViewState();
}

class _MapsViewState extends State<MapsView> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  MapType _currentMapType = MapType.normal;
  bool _isMapMenuExpanded = false;
  bool _isInfoExpanded = false;
  int _selectedRouteTab = 0; // 0: Frecuentes, 1: En Tiempo, 2: Todas
  RouteData? _currentSelectedRoute;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(20.543508165491687, -103.47583907776028),
    zoom: 14.4746,
  );
  
  static const Color primaryOrange = Color(0xFFFF6B35);

  @override
  void initState() {
    super.initState();
    // Fetch routes when view loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<RouteViewModel>();
      viewModel.fetchRoutes();
      viewModel.addListener(_onRouteViewModelChanged);
    });
  }

  @override
  void dispose() {
    try {
      context.read<RouteViewModel>().removeListener(_onRouteViewModelChanged);
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RouteViewModel>();
    
    // Generate markers and polylines
    final Set<Marker> markers = {};
    final Set<Polyline> polylines = {};
    
    if (viewModel.routeStops.isNotEmpty) {
      final points = viewModel.routeStops
          .map((stop) => LatLng(stop.latitud, stop.longitud))
          .toList();
      
      if (points.isNotEmpty) {
        polylines.add(
          Polyline(
            polylineId: const PolylineId('route_path'),
            points: points,
            color: primaryOrange,
            width: 5,
          ),
        );

        // Add start marker
        final firstStop = viewModel.routeStops.first;
        markers.add(
          Marker(
            markerId: const MarkerId('start'),
            position: points.first,
            infoWindow: InfoWindow(
              title: 'Inicio',
              snippet: firstStop.nombre ?? 'Primera parada',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ),
        );

        // Add end marker
        final lastStop = viewModel.routeStops.last;
        markers.add(
          Marker(
            markerId: const MarkerId('end'),
            position: points.last,
            infoWindow: InfoWindow(
              title: 'Fin',
              snippet: lastStop.nombre ?? 'Última parada',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
        
        // Add intermediate stops
        for (var i = 1; i < viewModel.routeStops.length - 1; i++) {
          final stop = viewModel.routeStops[i];
           markers.add(
            Marker(
              markerId: MarkerId('stop_$i'),
              position: LatLng(stop.latitud, stop.longitud),
              infoWindow: InfoWindow(
                title: stop.nombre ?? 'Parada ${stop.orden ?? i + 1}',
                snippet: 'Toca para más información',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
            ),
          );
        }
        
        // Move camera to fit route if stops just loaded
        // Note: This is a side effect in build, ideally should be done in a listener.
        // But for now we can check if we need to move camera.
        // We'll leave it for the user to move or implement a listener later.
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: Column(
          children: [
            // Header con LogoBusmen
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryOrange, Color(0xFFFF8C5A)],
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  // Logo Busmen
                  Image.asset(
                    'assets/images/logos/LogoBusmen.png',
                    width: 180,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  // Información del usuario
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: primaryOrange,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'User Name',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'user@email.com',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Lista de opciones
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    icon: Icons.person,
                    title: AppStrings.get('profile'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileView(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.directions_bus,
                    title: AppStrings.get('stops'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StopsView(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.support_agent,
                    title: AppStrings.get('assistance'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AssistanceChatView(),
                        ),
                      );
                    },
                  ),

                   _buildDrawerItem(
                    icon: Icons.error,
                    title: AppStrings.get('lostObjects'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LostObjectsView(),
                        ),
                      );
                    },
                  ),
                  
                  _buildDrawerItem(
                    icon: Icons.comment,
                    title: AppStrings.get('suggestions'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SuggestionsView(),
                        ),
                      );
                    },
                  ),

                   _buildDrawerItem(
                    icon: Icons.info,
                    title: AppStrings.get('information'),
                    onTap: () {
                      setState(() {
                        _isInfoExpanded = !_isInfoExpanded;
                      });
                    },
                    trailing: Icon(
                      _isInfoExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey[400],
                    ),
                  ),
                  
                  // Sub-opciones de Información (expandibles)
                  if (_isInfoExpanded) ...[
                    _buildDrawerSubItem(
                      icon: Icons.campaign,
                      title: AppStrings.get('announcements'),
                      onTap: () {
                        Navigator.pop(context);
                        // Navegar a Comunicados
                      },
                    ),
                    _buildDrawerSubItem(
                      icon: Icons.gavel,
                      title: AppStrings.get('regulations'),
                      onTap: () {
                        Navigator.pop(context);
                        // Navegar a Reglamentación
                      },
                    ),
                    _buildDrawerSubItem(
                      icon: Icons.menu_book,
                      title: AppStrings.get('userManual'),
                      onTap: () {
                        Navigator.pop(context);
                        // Navegar a Manual
                      },
                    ),
                  ],
                  
                  _buildDrawerItem(
                    icon: Icons.mood,
                    title: AppStrings.get('survey'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SurveyView(),
                        ),
                      );
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(),
                  ),
                  _buildDrawerItem(
                    icon: Icons.logout,
                    title: AppStrings.get('logout'),
                    iconColor: Colors.red,
                    textColor: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Mapa de fondo
          GoogleMap(
            mapType: _currentMapType,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: markers,
            polylines: polylines,
          ),
          
          // Botones flotantes en la parte superior
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botón de menú (izquierda)
                  _buildFloatingButton(
                    icon: Icons.menu,
                    onTap: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  
                  // Botón de notificaciones (derecha)
                  _buildFloatingButton(
                    icon: Icons.notifications,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsView(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // FAB Menu en la parte inferior derecha
          Positioned(
            right: 16,
            bottom: 100, // Arriba del botón de "Mi ubicación"
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Opciones expandidas
                if (_isMapMenuExpanded) ...[
                  _buildMapTypeOption(
                    icon: Icons.map,
                    label: AppStrings.get('mapTypeNormal'),
                    isSelected: _currentMapType == MapType.normal,
                    onTap: () {
                      setState(() {
                        _currentMapType = MapType.normal;
                        _isMapMenuExpanded = false;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMapTypeOption(
                    icon: Icons.satellite,
                    label: AppStrings.get('mapTypeSatellite'),
                    isSelected: _currentMapType == MapType.satellite,
                    onTap: () {
                      setState(() {
                        _currentMapType = MapType.satellite;
                        _isMapMenuExpanded = false;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMapTypeOption(
                    icon: Icons.terrain,
                    label: AppStrings.get('mapTypeHybrid'),
                    isSelected: _currentMapType == MapType.hybrid,
                    onTap: () {
                      setState(() {
                        _currentMapType = MapType.hybrid;
                        _isMapMenuExpanded = false;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                // Botón principal
                _buildFloatingButton(
                  icon: _isMapMenuExpanded ? Icons.close : Icons.layers,
                  onTap: () {
                    setState(() {
                      _isMapMenuExpanded = !_isMapMenuExpanded;
                    });
                  },
                ),
              ],
            ),
          ),
          
          
          // Menú de Tipos de Mapa (FAB)
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isMapMenuExpanded) ...[
                  _buildMapTypeOption(
                    icon: Icons.map_outlined,
                    label: AppStrings.get('mapTypeNormal'),
                    isSelected: _currentMapType == MapType.normal,
                    onTap: () {
                      setState(() {
                        _currentMapType = MapType.normal;
                        _isMapMenuExpanded = false;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMapTypeOption(
                    icon: Icons.satellite_outlined,
                    label: AppStrings.get('mapTypeSatellite'),
                    isSelected: _currentMapType == MapType.satellite,
                    onTap: () {
                      setState(() {
                        _currentMapType = MapType.satellite;
                        _isMapMenuExpanded = false;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMapTypeOption(
                    icon: Icons.terrain_outlined,
                    label: AppStrings.get('mapTypeHybrid'),
                    isSelected: _currentMapType == MapType.hybrid,
                    onTap: () {
                      setState(() {
                        _currentMapType = MapType.hybrid;
                        _isMapMenuExpanded = false;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                _buildFloatingButton(
                  icon: _isMapMenuExpanded ? Icons.close : Icons.layers,
                  onTap: () {
                    setState(() {
                      _isMapMenuExpanded = !_isMapMenuExpanded;
                    });
                  },
                ),
              ],
            ),
          ),

          // Banner de Estado de Ruta (Izquierda)
          Positioned(
            left: 16,
            right: 90, // Dejar espacio para el FAB
            bottom: 100, // Alineado con el FAB
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: _currentSelectedRoute != null 
                      ? (_currentSelectedRoute!.isActiveNow() ? Colors.green.withOpacity(0.5) : Colors.orange.withOpacity(0.5))
                      : Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentSelectedRoute != null 
                              ? _currentSelectedRoute!.displayName
                              : AppStrings.get('noRouteSelected'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _currentSelectedRoute != null 
                                    ? (_currentSelectedRoute!.isActiveNow() ? Colors.green : Colors.orange)
                                    : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _currentSelectedRoute != null 
                                    ? (_currentSelectedRoute!.isActiveNow() 
                                        ? '${AppStrings.get('routeActive')} (${_currentSelectedRoute!.timeRange})' 
                                        : '${AppStrings.get('outOfSchedule')} (${_currentSelectedRoute!.timeRange})')
                                    : AppStrings.get('selectRouteMsg'),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (_currentSelectedRoute != null)
                    Icon(
                      _currentSelectedRoute!.isActiveNow() ? Icons.check_circle_outline : Icons.schedule,
                      color: _currentSelectedRoute!.isActiveNow() ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),

          
          Positioned(
            left: 16,
            right: 90, 
            bottom: 30, 
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  _showRouteSelectionSheet(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.route, size: 20),
                label: Text(
                  AppStrings.get('selectRoute'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFloatingButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: primaryOrange,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 28,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? primaryOrange).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor ?? primaryOrange,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: trailing ?? Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hoverColor: primaryOrange.withOpacity(0.05),
      ),
    );
  }
  
  Widget _buildDrawerSubItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 40, right: 12, top: 4, bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: primaryOrange.withOpacity(0.7),
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey[400],
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hoverColor: primaryOrange.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }
  
  Widget _buildMapTypeOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? primaryOrange : Colors.black87,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Icon button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected ? primaryOrange : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : primaryOrange,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  void _showRouteSelectionSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      // Variable local para manejar la navegación interna del sheet
      RouteData? selectedRouteDetail;
      String? selectedRouteGroupName;

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setSheetState) {
          return Consumer<RouteViewModel>(
            builder: (context, viewModel, child) {
              
              // Determine title based on state
              String title = AppStrings.get('selectRoute');
              if (selectedRouteDetail != null) {
                title = selectedRouteDetail!.displayName;
              } else if (selectedRouteGroupName != null) {
                title = selectedRouteGroupName!;
              }

              return Container(
                height: MediaQuery.of(context).size.height * 0.8, // Aumenté la altura
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    // Header dinámico
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryOrange.withOpacity(0.05),
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
                          Row(
                            children: [
                              if (selectedRouteDetail != null || selectedRouteGroupName != null)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                                    onPressed: () {
                                      setSheetState(() {
                                        if (selectedRouteDetail != null) {
                                          // Si estamos viendo el detalle de una ruta específica
                                          if (_selectedRouteTab == 2 && selectedRouteGroupName != null) {
                                            // En la pestaña "Todas", regresar a la vista del grupo
                                            selectedRouteDetail = null;
                                          } else {
                                            // En otras pestañas, regresar a la lista
                                            selectedRouteDetail = null;
                                          }
                                        } else if (selectedRouteGroupName != null) {
                                          // Si estamos viendo un grupo, regresar a la lista principal
                                          selectedRouteGroupName = null;
                                        }
                                      });
                                    },
                                    color: primaryOrange,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),

                    // Contenido dinámico
                    if (viewModel.isLoading)
                      const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: primaryOrange,
                          ),
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
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => viewModel.refreshRoutes(),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reintentar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryOrange,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (selectedRouteDetail != null)
                      Expanded(
                        child: _buildRouteDetailView(selectedRouteDetail!),
                      )
                    else if (selectedRouteGroupName != null)
                      Expanded(
                        child: _buildRouteGroupDetailView(viewModel, selectedRouteGroupName!, (route) {
                          // Cuando se selecciona una ruta específica del grupo, seleccionarla y cerrar
                          setState(() {
                            _currentSelectedRoute = route;
                          });
                          
                          // Fetch route stops
                          context.read<RouteViewModel>().fetchStopsForRoute(route.claveRuta);
                          
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${AppStrings.get('selected')} ${route.displayName}')),
                          );
                        }),
                      )
                    else ...[ 
                      // Navigation Tabs
                      Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _buildTabItem(AppStrings.get('frequent'), 0, setSheetState),
                            _buildTabItem(AppStrings.get('onTime'), 1, setSheetState),
                            _buildTabItem(AppStrings.get('all'), 2, setSheetState),
                          ],
                        ),
                      ),

                      // Route List
                      Expanded(
                        child: _buildRouteList(viewModel, _selectedRouteTab, (item) {
                          if (_selectedRouteTab == 2) {
                            // In "Todas" tab, item is a String (route name)
                            setSheetState(() {
                              selectedRouteGroupName = item as String;
                            });
                          } else {
                            // In other tabs, item is RouteData
                            final route = item as RouteData;
                            setSheetState(() {
                              selectedRouteDetail = route;
                            });
                          }
                        }),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}

  Widget _buildRouteDetailView(RouteData route) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta de información general
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryOrange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: primaryOrange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Información de ${route.nombreRuta}',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Información de la ruta
          _buildInfoCard(
            icon: Icons.route,
            title: 'Clave de Ruta',
            value: route.claveRuta,
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          
          _buildInfoCard(
            icon: Icons.wb_sunny,
            title: 'Turno',
            value: route.turnoRuta,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          
          _buildInfoCard(
            icon: Icons.navigation,
            title: 'Dirección',
            value: route.direccionRuta,
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          
          _buildInfoCard(
            icon: Icons.access_time,
            title: 'Horario',
            value: route.timeRange,
            color: Colors.purple,
          ),
          const SizedBox(height: 12),
          
          _buildInfoCard(
            icon: Icons.category,
            title: 'Tipo de Ruta',
            value: route.tipoRuta,
            color: Colors.teal,
          ),
          const SizedBox(height: 24),
          
          // Días de operación
          Text(
            'Días de Operación',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: route.diaRuta.map((dia) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryOrange.withOpacity(0.3)),
              ),
              child: Text(
                dia,
                style: const TextStyle(
                  color: primaryOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 32),
          
          // Botón para ver en mapa
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _currentSelectedRoute = route;
                });
                
                // Fetch route stops
                context.read<RouteViewModel>().fetchStopsForRoute(route.claveRuta);
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${AppStrings.get('selected')} ${route.displayName}')),
                );
              },
              icon: const Icon(Icons.map),
              label: const Text(
                'Ver en Mapa',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index, StateSetter setSheetState) {
    final bool isSelected = _selectedRouteTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setSheetState(() {
            _selectedRouteTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryOrange : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryOrange.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteList(RouteViewModel viewModel, int tabIndex, Function(dynamic) onItemTap) {
    if (tabIndex == 2) {
      // Show unique route names
      final routeNames = viewModel.getUniqueRouteNames();
      
      if (routeNames.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: routeNames.length,
        itemBuilder: (context, index) {
          final name = routeNames[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_bus, color: primaryOrange),
              ),
              title: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () => onItemTap(name),
            ),
          );
        },
      );
    }

    // Original logic for other tabs
    final List<RouteData> displayedRoutes = viewModel.getRoutesForTab(tabIndex);

    if (displayedRoutes.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: displayedRoutes.length,
      itemBuilder: (context, index) {
        final route = displayedRoutes[index];
        final isActive = route.isActiveNow();
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.directions_bus, color: primaryOrange),
            ),
            title: Text(
              route.displayName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green : Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        isActive ? 'Activa' : 'Fuera de horario',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        route.timeRange,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? Colors.green.withOpacity(0.1) : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
                ),
              ),
              child: Text(
                route.turnoRuta,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.green : Colors.black87,
                  fontSize: 12,
                ),
              ),
            ),
            onTap: () => onItemTap(route),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
    );
  }

  /// Formatea los días de forma compacta (ej: LUN-VIE, SÁB-DOM, LUN, MIÉ, VIE)
  String _formatDaysCompact(List<String> days) {
    if (days.isEmpty) return '';
    
    // Mapeo de días completos a abreviaciones
    final Map<String, String> dayAbbrev = {
      'Lunes': 'LUN',
      'Martes': 'MAR',
      'Miércoles': 'MIÉ',
      'Miercoles': 'MIÉ', // Sin acento también
      'Jueves': 'JUE',
      'Viernes': 'VIE',
      'Sábado': 'SÁB',
      'Sabado': 'SÁB', // Sin acento también
      'Domingo': 'DOM',
    };

    // Orden de días de la semana
    final List<String> weekOrder = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    
    // Normalizar los días (por si vienen con mayúsculas/minúsculas diferentes)
    List<String> normalizedDays = days.map((d) {
      String lower = d.toLowerCase();
      return weekOrder.firstWhere(
        (wd) => wd.toLowerCase() == lower,
        orElse: () => d,
      );
    }).toList();

    // Si son días consecutivos, mostrar rango
    if (normalizedDays.length >= 2) {
      // Verificar si son consecutivos
      List<int> indices = normalizedDays.map((d) => weekOrder.indexOf(d)).where((i) => i != -1).toList();
      indices.sort();
      
      bool consecutive = true;
      for (int i = 1; i < indices.length; i++) {
        if (indices[i] != indices[i-1] + 1) {
          consecutive = false;
          break;
        }
      }
      
      if (consecutive && indices.isNotEmpty) {
        String first = dayAbbrev[weekOrder[indices.first]] ?? normalizedDays.first.substring(0, 3).toUpperCase();
        String last = dayAbbrev[weekOrder[indices.last]] ?? normalizedDays.last.substring(0, 3).toUpperCase();
        return '$first-$last';
      }
    }
    
    // Si no son consecutivos, mostrar todos abreviados
    return normalizedDays.map((d) => dayAbbrev[d] ?? d.substring(0, 3).toUpperCase()).join(', ');
  }

//MODIFICACION 
  Widget _buildRouteGroupDetailView(RouteViewModel viewModel, String routeName, Function(RouteData) onRouteTap) {
  final routes = viewModel.getRoutesByName(routeName);
  final groupedRoutes = viewModel.getRoutesGroupedByDirection(routes);
  
  // Debug: print what we got
  print('Routes for $routeName: ${routes.length} routes');
  print('Grouped directions: ${groupedRoutes.keys.toList()}');
  
  if (routes.isEmpty) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No se encontraron rutas para $routeName',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  return SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mostrar todas las direcciones que encontremos
        ...groupedRoutes.entries.map((entry) {
          final direction = entry.key;
          final directionRoutes = viewModel.getSortedRoutes(entry.value);
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                direction.toUpperCase(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              ...directionRoutes.map((route) => _buildGroupedRouteItem(route, onRouteTap)),
              const SizedBox(height: 24),
            ],
          );
        }).toList(),
      ],
    ),
  );
}
//MODIFICACION
  LatLngBounds _createBounds(List<LatLng> positions) {
    final southwestLat = positions.map((p) => p.latitude).reduce((value, element) => value < element ? value : element);
    final southwestLon = positions.map((p) => p.longitude).reduce((value, element) => value < element ? value : element);
    final northeastLat = positions.map((p) => p.latitude).reduce((value, element) => value > element ? value : element);
    final northeastLon = positions.map((p) => p.longitude).reduce((value, element) => value > element ? value : element);
    return LatLngBounds(
        southwest: LatLng(southwestLat, southwestLon),
        northeast: LatLng(northeastLat, northeastLon)
    );
  }

  void _onRouteViewModelChanged() {
    final viewModel = context.read<RouteViewModel>();
    // Only move camera if we have stops and we haven't moved it yet for this route?
    // For now, let's just move it whenever stops are loaded.
    // We can check if isLoadingStops changed from true to false.
    
    if (!viewModel.isLoadingStops && viewModel.routeStops.isNotEmpty) {
      final points = viewModel.routeStops
          .map((stop) => LatLng(stop.latitud, stop.longitud))
          .toList();
      
      if (points.isNotEmpty) {
        _controller.future.then((controller) {
          try {
            final bounds = _createBounds(points);
            controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
          } catch (e) {
            print('Error moving camera: $e');
          }
        });
      }
    }
  }

 Widget _buildGroupedRouteItem(RouteData route, Function(RouteData) onTap) {
  return GestureDetector(
    onTap: () => onTap(route),
    child: Container(
      margin: const EdgeInsets.only(bottom: 16), // Más espacio entre items
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time column
            SizedBox(
              width: 70,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.horaInicioRuta,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: primaryOrange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    route.turnoRuta,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Route info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.nombreRuta,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Days with icons
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _formatDaysCompact(route.diaRuta),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Time range
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        route.timeRange,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    ),
  );
}
  }

