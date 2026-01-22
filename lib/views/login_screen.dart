import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screen_protector/screen_protector.dart';

import '../services/UserSession.dart';
import '../viewModel/login/UserViewModel.dart';
import 'maps_view.dart';
import '../utils/app_strings.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();

}

class _LoginScreenState extends State<LoginScreen> {


  static const Color primaryOrange = Color(0xFFFF6B35);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final session = UserSession();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    session.clear();
    
    // Asegurar que las capturas estén permitidas al volver al login
    ScreenProtector.preventScreenshotOff();
    
    _emailController.text = session.isPersist ? session.email ?? '' : '';
    _pwdController.text = session.isPersist ? session.token ?? '' : '';
  }

  void _showLanguageSelectionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.get('selectLanguage'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            ListTile(
              
              title: Text(AppStrings.get('spanish')),
              trailing: AppStrings.currentLanguage == 'es' 
                  ? const Icon(Icons.check, color: primaryOrange) 
                  : null,
              onTap: () {
                setState(() {
                  AppStrings.setLanguage('es');
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              
              title: Text(AppStrings.get('english')),
              trailing: AppStrings.currentLanguage == 'en' 
                  ? const Icon(Icons.check, color: primaryOrange) 
                  : null,
              onTap: () {
                setState(() {
                  AppStrings.setLanguage('en');
                });
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showRecoverySheet() {
    final TextEditingController emailController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.get('recoverTitle'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get('recoverDescription'),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    Text(
                      AppStrings.get('emailLabel'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: AppStrings.get('emailHint'),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryOrange),
                        ),
                        prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (emailController.text.isNotEmpty) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppStrings.get('instructionsSent')),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          AppStrings.get('sendInstructions'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Inicio de sesión',
                                        style: TextStyle(
                                          fontSize: isTabletOrDesktop ? 28 : 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      qrMercadoLibreButton(
                                        context: context,
                                        viewModel: vm,
                                      ),
                                    ],
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
                                    controller: _emailController,
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
                                    controller: _pwdController,
                                    obscureText: _obscurePassword,
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
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: isTabletOrDesktop ? 25 : 20),

                                  // Mantener sesión y cambiar idioma
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: vm.togglePersistSession,
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

                                        // print("=> success: $success");
                                        if (success) {
                                          session.isLogin = success;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => const MapsView()),
                                          );
                                          // print("=> entrar");
                                          // session.clear();
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

  Widget qrMercadoLibreButton({
    required BuildContext context,
    required LoginViewModel viewModel,
  }) {
    if (UserSession().textQR == null || UserSession().textQR!.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool isExpired = UserSession().isQRExpired();

    return InkWell(
      onTap: isExpired 
        ? () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tu pase ha vencido. Por favor, inicia sesión nuevamente.'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        : () => _showUserQRSheet(),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isExpired ? Colors.grey[700] : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isExpired ? Icons.history_rounded : Icons.qr_code_scanner_rounded, 
              size: 20, 
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              'QR',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showUserQRSheet() async {
    final mercadoLibre = "mercadolibregdl";
    final mercadoLibre2 = "mercadolibregdl2";
    final companyClave = UserSession().getCompanyData()?.clave ?? UserSession().lastCompanyClave;
    final isMercadoLibre = companyClave == mercadoLibre || companyClave == mercadoLibre2;

    String userName = UserSession().nameQR.toString()!;
    String userId = UserSession().textQR!;

    // Solo activar protección si es Mercado Libre
    if (isMercadoLibre) {
      await ScreenProtector.preventScreenshotOn();
    } else {
      await ScreenProtector.preventScreenshotOff();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WillPopScope(
        onWillPop: () async {
          await ScreenProtector.preventScreenshotOff();
          return true;
        },
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 34),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Pase de Acceso',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 6,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E293B),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF1E293B).withOpacity(0.05),
                              ),
                              child: const Icon(Icons.person, size: 48, color: Color(0xFF1E293B)),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'PERSONAL AUTORIZADO',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Divider(height: 1),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: QrImageView(
                                data: userId,
                                version: QrVersions.auto,
                                size: 160,
                                backgroundColor: Colors.white,
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: Colors.black,
                                ),
                                dataModuleStyle: const QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              userId,
                              style: const TextStyle(
                                fontSize: 13,
                                fontFamily: 'Monospace',
                                color: Color(0xFF64748B),
                                letterSpacing: 3,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer_outlined, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 8),
                    Text(
                      'Vigencia restante: ${UserSession().getDaysRemaining()} días',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.nfc, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 8),
                    Text(
                      'Acerca al lector para registrar entrada',
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
        ),
      ),
    ).then((_) {
      // Siempre desactivar al cerrar por seguridad
      ScreenProtector.preventScreenshotOff();
    });
  }

}
