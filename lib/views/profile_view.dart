import 'package:flutter/material.dart';
import 'package:geovoy_app/services/UserSession.dart';
import 'package:geovoy_app/views/widgets/BuildQrProfileWidget.dart';
import '../utils/app_strings.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  static const Color primaryOrange = Color(0xFFFF6B35);

  final session = UserSession();

  // Datos del usuario (temporales)
  late final String? userName = session.getUserData()?.nombre;//'User Name';
  late final String? userEmail = session.getUserData()?.email; //'user@email.com';
  late final String? supportPhone = session.getCompanyData()?.telefonos;//'+52 123 456 7890';

  late String? qr_text = session.getUserData()?.idCli.toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('profile')),
        backgroundColor: primaryOrange,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              
              // Campos de información
              Text(
                AppStrings.get('personalInfo'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Campo Usuario
              _buildInfoCard(
                icon: Icons.person_outline,
                label: AppStrings.get('userLabel'),
                value: userName,
              ),
              const SizedBox(height: 16),

              // Campo Email
              _buildInfoCard(
                icon: Icons.email_outlined,
                label: 'Email',
                value: userEmail,
              ),
              const SizedBox(height: 16),

              // Campo Teléfono de soporte
              _buildInfoCard(
                icon: Icons.phone_outlined,
                label: AppStrings.get('supportPhone'),
                value: supportPhone,
              ),
              const SizedBox(height: 32),

              // Sección QR
              Text(
                AppStrings.get('qrCode'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Espacio para QR
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primaryOrange.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildSafeQRCode( qr_text! ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.get('qrCode'),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Botón Eliminar Cuenta
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(AppStrings.get('deleteAccount')),
                        content: Text(AppStrings.get('deleteAccountMsg')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(AppStrings.get('cancel')),
                          ),
                          TextButton(
                            onPressed: () {
                              // Aquí iría la lógica de eliminación
                              Navigator.pop(context);
                            },
                            child: Text(
                              AppStrings.get('delete'),
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    AppStrings.get('deleteAccount'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String? value,
  }) {
    return Container(
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
      child: Row(
        children: [
          // Icono
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: primaryOrange,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}