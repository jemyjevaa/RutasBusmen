import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controller/login/UserModel.dart';
import 'maps_view.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  @override
  Widget build(BuildContext context) {
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
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Consumer<LoginViewModel>(
                      builder: (context, vm, child) {
                        final size = MediaQuery.of(context).size;
                        final bool isTabletOrDesktop = size.width > 600;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: isTabletOrDesktop ? 40 : 20),
                            Image.asset(
                              'assets/images/logos/LogoBusmen.png',
                              fit: BoxFit.contain,
                              width: isTabletOrDesktop ? 300 : 200,
                              height: isTabletOrDesktop ? 100 : 90,
                            ),
                            SizedBox(height: isTabletOrDesktop ? 40 : 30),
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
                                  Text(
                                    'Inicio de sesión',
                                    style: TextStyle(
                                      fontSize: isTabletOrDesktop ? 28 : 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: isTabletOrDesktop ? 25 : 20),

                                  // Usuario
                                  Text(
                                    'Usuario',
                                    style: TextStyle(
                                      fontSize: isTabletOrDesktop ? 18 : 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    keyboardType: TextInputType.emailAddress,
                                    autocorrect: false,
                                    onChanged: vm.setUsername,
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
                                  SizedBox(height: isTabletOrDesktop ? 25 : 20),

                                  // Contraseña
                                  Text(
                                    'Contraseña',
                                    style: TextStyle(
                                      fontSize: isTabletOrDesktop ? 18 : 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    obscureText: true,
                                    autocorrect: false,
                                    onChanged: vm.setPassword,
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
                                  SizedBox(height: isTabletOrDesktop ? 25 : 20),

                                  // Mantener sesión y cambiar idioma
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: vm.toggleMantenerSesion,
                                          child: Row(
                                            children: [
                                              Icon(
                                                vm.mantenerSesion ? Icons.check_box : Icons.check_box_outline_blank,
                                                color: vm.mantenerSesion ? const Color(0xFFFF6B35) : Colors.grey,
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
                                      IconButton(
                                        onPressed: () {
                                          // Aquí pones la lógica para cambiar idioma
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

                                  // Botón iniciar sesión
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: vm.isLoading
                                          ? null
                                          : () async {
                                        bool success = await vm.login();
                                        if (success) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => const MapsView()),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Credenciales incorrectas')),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFF6B35),
                                        padding: EdgeInsets.symmetric(
                                          vertical: isTabletOrDesktop ? 18 : 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: vm.isLoading
                                          ? const CircularProgressIndicator(color: Colors.white)
                                          : const Text(
                                        'INICIAR SESIÓN',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Botón recuperar contraseña
                                  Center(
                                    child: TextButton(
                                      onPressed: () {
                                        // Aquí la lógica para recuperar contraseña
                                      },
                                      child: Text(
                                        'Recuperar contraseña',
                                        style: TextStyle(
                                          fontSize: isTabletOrDesktop ? 18 : 14,
                                          color: const Color(0xFF007AFF),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: isTabletOrDesktop ? 40 : 30),

                            // Footer logo y versión
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

                            const SizedBox(height: 20),
                          ],
                        );
                      },
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
