import 'package:flutter/material.dart';
import '../utils/app_strings.dart';
import '../widgets/route_selector.dart';
import '../models/route_model.dart';
import '../widgets/animated_result_dialog.dart';

class LostObjectsView extends StatefulWidget {
  const LostObjectsView({super.key});

  @override
  State<LostObjectsView> createState() => _LostObjectsViewState();
}

class _LostObjectsViewState extends State<LostObjectsView> {
  static const Color primaryOrange = Color(0xFFFF6B35);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  RouteData? _selectedRoute;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryOrange,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
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
      if (_selectedDate == null) {
        AnimatedResultDialog.showError(
          context,
          title: 'Error',
          message: AppStrings.get('dateError'),
        );
        return;
      }

      // Aquí iría la lógica para enviar el formulario
      AnimatedResultDialog.showSuccess(
        context,
        title: '¡Gracias!',
        message: AppStrings.get('reportSent'),
        onDismiss: () {
          // Optional: Navigate back or do something else
        },
      );

      // Limpiar formulario
      _nameController.clear();
      _phoneController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedRoute = null;
        _selectedDate = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('lostObjects')),
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
                // Header con icono
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryOrange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.search,
                      size: 60,
                      color: primaryOrange,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    AppStrings.get('reportLostObject'),
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
                    AppStrings.get('fillFormMsg'),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),

                // Campo Nombre
                _buildLabel(AppStrings.get('nameLabel')),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration(
                    hint: AppStrings.get('nameHint'),
                    icon: Icons.person_outline,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.get('nameError');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo Teléfono
                _buildLabel(AppStrings.get('phoneLabel')),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _buildInputDecoration(
                    hint: AppStrings.get('phoneHint'),
                    icon: Icons.phone_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.get('phoneError');
                    }
                    if (value.length < 10) {
                      return AppStrings.get('phoneInvalid');
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

                // Selector de Fecha
                _buildLabel(AppStrings.get('dateLabel')),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: primaryOrange),
                        const SizedBox(width: 16),
                        Text(
                          _selectedDate == null
                              ? AppStrings.get('selectDate')
                              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedDate == null
                                ? Colors.grey[400]
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Campo Descripción
                _buildLabel(AppStrings.get('descriptionLabel')),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: _buildInputDecoration(
                    hint: AppStrings.get('descriptionHint'),
                    icon: Icons.description_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.get('descriptionError');
                    }
                    if (value.length < 10) {
                      return AppStrings.get('descriptionLengthError');
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
                          AppStrings.get('submitReport'),
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
