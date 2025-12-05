import 'package:flutter/material.dart';
import '../utils/app_strings.dart';
import '../widgets/route_selector.dart';
import '../models/route_model.dart';
import '../widgets/animated_result_dialog.dart';

class SuggestionsView extends StatefulWidget {
  const SuggestionsView({super.key});

  @override
  State<SuggestionsView> createState() => _SuggestionsViewState();
}

class _SuggestionsViewState extends State<SuggestionsView> {
  static const Color primaryOrange = Color(0xFFFF6B35);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _unitController = TextEditingController();
  final _commentController = TextEditingController();
  
  RouteData? _selectedRoute;
  String? _selectedSchedule;

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
    _unitController.dispose();
    _commentController.dispose();
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

      AnimatedResultDialog.showSuccess(
        context,
        title: '¡Gracias!',
        message: AppStrings.get('suggestionSent'),
        onDismiss: () {
          // Optional: Navigate back or do something else
        },
      );

      // Limpiar formulario
      _nameController.clear();
      _emailController.clear();
      _unitController.clear();
      _commentController.clear();
      setState(() {
        _selectedRoute = null;
        _selectedSchedule = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('suggestions')),
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
                      Icons.lightbulb_outline,
                      size: 60,
                      color: primaryOrange,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    AppStrings.get('yourSuggestionsMatters'),
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
                    AppStrings.get('helpUsImprove'),
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
                _buildLabel(AppStrings.get('selectRouteLabel')),
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
                _buildLabel(AppStrings.get('selectScheduleLabel')),
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
                const SizedBox(height: 20),

                // Campo Unidad
                _buildLabel(AppStrings.get('unitLabel')),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _unitController,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDecoration(
                    hint: AppStrings.get('unitHint'),
                    icon: Icons.directions_bus,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.get('unitError');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo Comentario
                _buildLabel(AppStrings.get('commentLabel')),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _commentController,
                  maxLines: 5,
                  decoration: _buildInputDecoration(
                    hint: AppStrings.get('commentHint'),
                    icon: Icons.comment_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.get('commentError');
                    }
                    if (value.length < 10) {
                      return AppStrings.get('commentLengthError');
                    }
                    return null;
                  },
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
                          AppStrings.get('sendSuggestion'),
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
