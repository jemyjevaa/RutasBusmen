import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'notifications_view.dart';
import 'profile_view.dart';
import 'stops_view.dart';
import 'lost_objects_view.dart';
import 'suggestions_view.dart';
import 'survey_view.dart';
import 'login_screen.dart';
import '../utils/app_strings.dart';

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
  Map<String, dynamic>? _currentSelectedRoute;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(20.543508165491687, -103.47583907776028),
    zoom: 14.4746,
  );
  
  static const Color primaryOrange = Color(0xFFFF6B35);

  @override
  Widget build(BuildContext context) {
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
                      ? (_currentSelectedRoute!['status'] == 'Retrasado' ? Colors.red.withOpacity(0.5) : Colors.green.withOpacity(0.5))
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
                              ? _currentSelectedRoute!['name'] 
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
                                    ? (_currentSelectedRoute!['status'] == 'Retrasado' ? Colors.red : Colors.green)
                                    : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _currentSelectedRoute != null 
                                    ? (_currentSelectedRoute!['status'] == 'Retrasado' ? AppStrings.get('outOfSchedule') : AppStrings.get('routeActive'))
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
                      _currentSelectedRoute!['status'] == 'Retrasado' ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                      color: _currentSelectedRoute!['status'] == 'Retrasado' ? Colors.red : Colors.green,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),

          // Botón "Seleccionar Ruta" (Izquierda, abajo)
          Positioned(
            left: 16,
            right: 90, // Dejar espacio para el FAB (aunque esté más arriba, mantiene alineación visual)
            bottom: 30, // Un poco más abajo
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
        Map<String, dynamic>? selectedRouteDetail;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Header dinámico
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
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
                            if (selectedRouteDetail != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                                  onPressed: () {
                                    setSheetState(() {
                                      selectedRouteDetail = null;
                                    });
                                  },
                                  color: primaryOrange,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            Text(
                              selectedRouteDetail != null 
                                ? selectedRouteDetail!['name'] 
                                : AppStrings.get('selectRoute'),
                              style: const TextStyle(
                                fontSize: 20,
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
                  if (selectedRouteDetail != null)
                    Expanded(
                      child: _buildRouteDetailView(selectedRouteDetail!),
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
                      child: _buildRouteList(_selectedRouteTab, (route) {
                        // Callback cuando se selecciona una ruta
                        if (_selectedRouteTab == 2) {
                          // En la pestaña TODAS, navegar al detalle
                          setSheetState(() {
                            selectedRouteDetail = route;
                          });
                        } else {
                          // En otras pestañas, comportamiento normal (seleccionar y cerrar)
                          setState(() {
                            _currentSelectedRoute = route;
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${AppStrings.get('selected')} ${route['name']}')),
                          );
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
  }

  Widget _buildRouteDetailView(Map<String, dynamic> route) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
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
                    '${AppStrings.get('availableSchedules')} ${route['name']}',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna Entradas
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.login, size: 18, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            AppStrings.get('entries'),
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List<String>.from(route['entradas']).map((time) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
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
                      child: Text(
                        time,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Columna Salidas
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.logout, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            AppStrings.get('exits'),
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List<String>.from(route['salidas']).map((time) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
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
                      child: Text(
                        time,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
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

  Widget _buildRouteList(int tabIndex, Function(Map<String, dynamic>) onRouteTap) {
    // Mock data for routes with schedules
    final List<Map<String, dynamic>> allRoutes = [
      {
        'name': 'SOLEDAD',
        'status': 'A tiempo',
        'time': '5 min',
        'entradas': ['06:00 AM', '07:30 AM', '09:00 AM', '10:30 AM', '12:00 PM'],
        'salidas': ['06:45 AM', '08:15 AM', '09:45 AM', '11:15 AM', '12:45 PM']
      },
      {
        'name': 'LA VIRGEN',
        'status': 'Retrasado',
        'time': '12 min',
        'entradas': ['06:15 AM', '07:45 AM', '09:15 AM', '10:45 AM'],
        'salidas': ['07:00 AM', '08:30 AM', '10:00 AM', '11:30 AM']
      },
      {
        'name': 'SALK',
        'status': 'A tiempo',
        'time': '8 min',
        'entradas': ['06:30 AM', '08:00 AM', '09:30 AM', '11:00 AM'],
        'salidas': ['07:15 AM', '08:45 AM', '10:15 AM', '11:45 AM']
      },
      {
        'name': 'OLINDA',
        'status': 'A tiempo',
        'time': '3 min',
        'entradas': ['05:45 AM', '07:15 AM', '08:45 AM', '10:15 AM'],
        'salidas': ['06:30 AM', '08:00 AM', '09:30 AM', '11:00 AM']
      },
      {
        'name': 'SAUCITO',
        'status': 'Llegando',
        'time': '1 min',
        'entradas': ['06:10 AM', '07:40 AM', '09:10 AM', '10:40 AM'],
        'salidas': ['06:55 AM', '08:25 AM', '09:55 AM', '11:25 AM']
      },
    ];

    List<Map<String, dynamic>> displayedRoutes;
    if (tabIndex == 0) {
      // Frecuentes (mock filter)
      displayedRoutes = [allRoutes[0], allRoutes[3]];
    } else if (tabIndex == 1) {
      // En Tiempo (mock filter)
      displayedRoutes = allRoutes.where((r) => r['status'] == 'A tiempo' || r['status'] == 'Llegando').toList();
    } else {
      // Todas
      displayedRoutes = allRoutes;
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: displayedRoutes.length,
      itemBuilder: (context, index) {
        final route = displayedRoutes[index];
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
              route['name'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: route['status'] == 'Retrasado' ? Colors.red : Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  route['status'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            trailing: tabIndex == 2 
              ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    route['time'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                ),
            onTap: () => onRouteTap(route),
          ),
        );
      },
    );
  }
}
