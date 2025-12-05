import 'package:flutter/material.dart';
import '../utils/app_strings.dart';
import '../widgets/route_selector.dart';
import '../models/route_model.dart';
import '../widgets/animated_result_dialog.dart';

class SurveyView extends StatefulWidget {
  const SurveyView({super.key});

  @override
  State<SurveyView> createState() => _SurveyViewState();
}

class _SurveyViewState extends State<SurveyView> {
  static const Color primaryOrange = Color(0xFFFF6B35);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  RouteData? _selectedRoute;
  String? _selectedSchedule;
  
  // Calificaciones (1 = Malo, 5 = Excelente)
  int _cleanlinessRating = 0;
  int _attitudeRating = 0;
  int _drivingRating = 0;

  final List<String> _schedules = [
    '06:00 - 08:00',
    '08:00 - 10:00',
    '10:00 - 12:00',
    '12:00 - 14:00',
    '14:00 - 16:00',
    '16:00 - 18:00',
    '18:00 - 20:00',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedRoute == null) {
        AnimatedResultDialog.showError(
          context,
          title: 'Error',
          message: AppStrings.get('routeError'),
        );
        return;
      }
      if (_selectedSchedule == null) {
        AnimatedResultDialog.showError(
          context,
          title: 'Error',
          message: AppStrings.get('scheduleError'),
        );
        return;
      }
      if (_cleanlinessRating == 0 || _attitudeRating == 0 || _drivingRating == 0) {
        AnimatedResultDialog.showError(
          context,
          title: 'Error',
          message: AppStrings.get('rateAllAspects'),
        );
        return;
      }

      AnimatedResultDialog.showSuccess(
        context,
        title: '¡Gracias!',
        message: AppStrings.get('surveySent'),
        onDismiss: () {
          // Optional: Navigate back or do something else
        },
      );

      // Limpiar formulario
      _nameController.clear();
      _emailController.clear();
      setState(() {
        _selectedRoute = null;
        _selectedSchedule = null;
        _cleanlinessRating = 0;
        _attitudeRating = 0;
        _drivingRating = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('survey')),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryOrange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.poll,
                      size: 60,
                      color: primaryOrange,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    AppStrings.get('satisfactionSurvey'),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    AppStrings.get('yourOpinionHelps'),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Campo Usuario
                _buildLabel(AppStrings.get('userLabel')),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration(
                    hint: AppStrings.get('userHint'),
                    icon: Icons.person_outline,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.get('userError');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo Email
                _buildLabel(AppStrings.get('emailLabel')),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildInputDecoration(
                    hint: AppStrings.get('emailHint'),
                    icon: Icons.email_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.get('emailError');
                    }
                    if (!value.contains('@')) {
                      return AppStrings.get('emailInvalid');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Route Selector
                _buildLabel(AppStrings.get('routeLabel')),
                const SizedBox(height: 8),
                RouteSelector(
                  selectedRoute: _selectedRoute,
                  onRouteSelected: (route) {
                    setState(() {
                      _selectedRoute = route;
                    });
                  },
                  primaryColor: primaryOrange,
                ),
                const SizedBox(height: 20),

                // Selector de Horario
                _buildLabel(AppStrings.get('scheduleLabel')),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: _selectedSchedule,
                  hint: AppStrings.get('selectScheduleHint'),
                  icon: Icons.access_time,
                  items: _schedules,
                  onChanged: (value) {
                    setState(() {
                      _selectedSchedule = value;
                    });
                  },
                ),
                const SizedBox(height: 32),

                // Sección de Calificaciones
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryOrange.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: primaryOrange, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.get('rateService'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.get('ratingScale'),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 1. Limpieza de las unidades
                      _buildRatingItem(
                        title: AppStrings.get('unitCleanliness'),
                        icon: Icons.cleaning_services,
                        rating: _cleanlinessRating,
                        onRatingChanged: (rating) {
                          setState(() {
                            _cleanlinessRating = rating;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // 2. Actitud del operador
                      _buildRatingItem(
                        title: AppStrings.get('operatorAttitude'),
                        icon: Icons.emoji_emotions,
                        rating: _attitudeRating,
                        onRatingChanged: (rating) {
                          setState(() {
                            _attitudeRating = rating;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // 3. Forma de conducir del operador
                      _buildRatingItem(
                        title: AppStrings.get('operatorDriving'),
                        icon: Icons.drive_eta,
                        rating: _drivingRating,
                        onRatingChanged: (rating) {
                          setState(() {
                            _drivingRating = rating;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Botón Enviar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send, size: 20),
                        SizedBox(width: 12),
                        Text(
                          AppStrings.get('sendSurvey'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingItem({
    required String title,
    required IconData icon,
    required int rating,
    required Function(int) onRatingChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: primaryOrange, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final starRating = index + 1;
            return GestureDetector(
              onTap: () => onRatingChanged(starRating),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: rating >= starRating
                      ? primaryOrange
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: rating >= starRating
                        ? primaryOrange
                        : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$starRating',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: rating >= starRating
                          ? Colors.white
                          : Colors.grey[400],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.get('bad'),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              AppStrings.get('excellent'),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: primaryOrange),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      prefixIcon: Icon(icon, color: primaryOrange),
      filled: true,
      fillColor: Colors.white,
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
        borderSide: const BorderSide(color: primaryOrange, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
