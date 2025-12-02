import 'package:flutter/material.dart';
import 'maps_view.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
 
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  bool _mantenerSesion = false;
  bool _showLanguageSheet = false;
  

  static const Color primaryOrange = Color(0xFFFF6B35); 
  static const Color primaryBlue = Color(0xFF007AFF);    
  static const Color backgroundGray = Color(0xFFF5F5F7);
  
  
  bool get _isLargeScreen {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.shortestSide > 600;
  }
  
  bool get _isSmallDevice {
    return MediaQuery.of(context).size.height < 670;
  }

  @override
  Widget build(BuildContext context) {
    
    final size = MediaQuery.of(context).size;
    final bool isTabletOrDesktop = size.width > 600;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Fondo (Background)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/backgrounds/LOGIN.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Contenido (Content)
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 500, // Ancho máximo para que no se estire en tablets/PC
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Espacio superior dinámico
                      SizedBox(height: isTabletOrDesktop ? 40 : 20),

                      // Logo Busmen
                      Image.asset(
                        'assets/images/logos/LogoBusmen.png',
                        fit: BoxFit.contain,
                        width: isTabletOrDesktop ? 300 : 200,
                        height: isTabletOrDesktop ? 100 : 90,
                      ),
                      
                      SizedBox(height: isTabletOrDesktop ? 40 : 30),

                      // Tarjeta de Login
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: EdgeInsets.all(isTabletOrDesktop ? 40 : 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título "Inicio de sesión"
                            Text(
                              'Inicio de sesión',
                              style: TextStyle(
                                fontSize: isTabletOrDesktop ? 28 : 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: isTabletOrDesktop ? 25 : 20),

                            // 4. CAMPO USUARIO
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Usuario',
                                  style: TextStyle(
                                    fontSize: isTabletOrDesktop ? 18 : 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _usuarioController,
                                  keyboardType: TextInputType.emailAddress,
                                  autocorrect: false,
                                  decoration: InputDecoration(
                                    hintText: 'usuario@ejemplo.com',
                                    filled: true,
                                    fillColor: Colors.grey.withOpacity(0.1),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.all(isTabletOrDesktop ? 16 : 12),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isTabletOrDesktop ? 25 : 20),

                            // CAMPO CONTRASEÑA
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Contraseña',
                                  style: TextStyle(
                                    fontSize: isTabletOrDesktop ? 18 : 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _contrasenaController,
                                  obscureText: true,
                                  autocorrect: false,
                                  decoration: InputDecoration(
                                    hintText: '**********',
                                    filled: true,
                                    fillColor: Colors.grey.withOpacity(0.1),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.all(isTabletOrDesktop ? 16 : 12),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isTabletOrDesktop ? 25 : 20),

                            // Checkbox y Botón Idioma
                            Row(
                              children: [
                                // Checkbox "Mantener sesión iniciada"
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _mantenerSesion = !_mantenerSesion;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          _mantenerSesion
                                              ? Icons.check_box
                                              : Icons.check_box_outline_blank,
                                          color: _mantenerSesion ? primaryOrange : Colors.grey,
                                          size: isTabletOrDesktop ? 28 : 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Mantener sesión',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: isTabletOrDesktop ? 18 : 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Botón cambiar idioma
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _showLanguageSheet = true;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.language,
                                    color: Colors.grey,
                                    size: isTabletOrDesktop ? 28 : 24,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isTabletOrDesktop ? 25 : 20),

                            // Botón Iniciar Sesión
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Lógica de login aquí
                                  print('Iniciando sesión...');
                                  // Navegar a MapsView
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const MapsView()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryOrange,
                                  padding: EdgeInsets.symmetric(
                                    vertical: isTabletOrDesktop ? 18 : 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'INICIAR SESIÓN',
                                  style: TextStyle(
                                    fontSize: isTabletOrDesktop ? 18 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Botón Recuperar Contraseña
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  // Lógica de recuperación aquí
                                },
                                child: Text(
                                  'Recuperar contraseña',
                                  style: TextStyle(
                                    fontSize: isTabletOrDesktop ? 18 : 14,
                                    color: primaryBlue,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isTabletOrDesktop ? 40 : 30),

                      // Footer Logo y Versión
                      Column(
                        children: [
                          Image.asset(
                            'assets/images/logos/logoGeovoy.png',
                            fit: BoxFit.contain,
                            width: isTabletOrDesktop ? 140 : 100,
                            height: isTabletOrDesktop ? 50 : 35,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'v2.0',
                            style: TextStyle(
                              fontSize: isTabletOrDesktop ? 16 : 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      // Espacio extra al final para asegurar que se vea bien al hacer scroll
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}