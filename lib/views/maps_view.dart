import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geovoy_app/services/ResponseServ.dart';
import 'package:geovoy_app/views/login_screen.dart';
import 'package:geovoy_app/views/widgets/BuildImgWidget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/UserSession.dart';
import 'notifications_view.dart';
import 'profile_view.dart';
import 'stops_view.dart';
import 'lost_objects_view.dart';
import 'suggestions_view.dart';
import 'survey_view.dart';

class MapsView extends StatefulWidget {
  const MapsView({super.key});

  @override
  State<MapsView> createState() => _MapsViewState();
}

class _MapsViewState extends State<MapsView> {

  final session = UserSession();

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static CameraPosition kGooglePlex = const CameraPosition(
    target: LatLng(20.543508165491687, -103.47583907776028),
    zoom: 14.4746,
  );

  MapType _currentMapType = MapType.normal;
  bool _isMapMenuExpanded = false;
  bool _isInfoExpanded = false;
  
  static const Color primaryOrange = Color(0xFFFF6B35);

  @override
  Widget build(BuildContext context) {

    Empresa? company = session.getCompanyData();
    Usuario? user = session.getUserData();

    String urlImg = company?.imagen.replaceAll(RegExp(r"\s+"), "%20") ?? 'assets/images/logos/LogoBusmen.png';

    String? newLatLon = company?.latitudLongitud;

    double lat = double.parse(newLatLon!.split(",")[0]);
    double lon = double.parse(newLatLon!.split(",")[1]);

    moveCamera(lat, lon);


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
                  colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  // Logo Busmen
                  buildImage(urlImg),
                  // Image.asset(
                  //   urlImg,
                  //   width: 180,
                  //   height: 80,
                  //   fit: BoxFit.contain,
                  // ),
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
                        children:  [
                          Text(
                            user!.nombre,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            user!.email,
                            style: TextStyle(
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
                    title: 'Perfil',
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
                    title: 'Paradas',
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
                    title: 'Asistencia',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),

                   _buildDrawerItem(
                    icon: Icons.error,
                    title: 'Objetos Perdidos',
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
                    title: 'Sugerencias',
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
                    title: 'Información',
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
                      title: 'Comunicados',
                      onTap: () {
                        Navigator.pop(context);
                        // Navegar a Comunicados
                      },
                    ),
                    _buildDrawerSubItem(
                      icon: Icons.gavel,
                      title: 'Reglamentación',
                      onTap: () {
                        Navigator.pop(context);
                        // Navegar a Reglamentación
                      },
                    ),
                    _buildDrawerSubItem(
                      icon: Icons.menu_book,
                      title: 'Manual de Usuario',
                      onTap: () {
                        Navigator.pop(context);
                        // Navegar a Manual
                      },
                    ),
                  ],
                  
                  _buildDrawerItem(
                    icon: Icons.mood,
                    title: 'Encuesta',
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
                    title: 'Cerrar sesión',
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
                      // Cerrar sesión
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
            initialCameraPosition: kGooglePlex,
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
                    label: 'Normal',
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
                    label: 'Satélite',
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
                    label: 'Híbrido',
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
          
          // Botón "Seleccionar Ruta" en la parte inferior izquierda
          Positioned(
            left: 16,
            bottom: 100,
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
                  // Funcionalidad para seleccionar ruta (próximamente)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funcionalidad próximamente'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.route, size: 20),
                label: const Text(
                  'Seleccionar Ruta',
                  style: TextStyle(
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

  Future<void> moveCamera(double lat, double lng) async {
    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, lng),
          zoom: 15.0,  // Puedes ajustar el zoom
        ),
      ),
    );
  }

}


