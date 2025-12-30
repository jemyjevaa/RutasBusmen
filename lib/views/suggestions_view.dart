import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_strings.dart';
import '../viewModel/suggestions/suggestions_viewmodal.dart';
import '../widgets/route_selector.dart';

class SuggestionsView extends StatelessWidget {
  const SuggestionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SuggestionsViewModel(),
      child: const SuggestionsViewForm(),
    );
  }
}

class SuggestionsViewForm extends StatelessWidget {
  const SuggestionsViewForm({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SuggestionsViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('suggestions')),
        backgroundColor: SuggestionsViewModel.primaryOrange,
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
            key: viewModel.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: SuggestionsViewModel.primaryOrange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline,
                      size: 60,
                      color: SuggestionsViewModel.primaryOrange,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    AppStrings.get('yourSuggestionsMatters'),
                    style: const TextStyle(
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
                  controller: viewModel.nameController,
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
                  controller: viewModel.emailController,
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
                  selectedRoute: viewModel.selectedRoute,
                  onRouteSelected: (route) {
                    viewModel.setRoute(route);
                  },
                  primaryColor: SuggestionsViewModel.primaryOrange,
                ),
                const SizedBox(height: 20),

                // Campo Horario
                _buildLabel(AppStrings.get('selectScheduleLabel')),
                const SizedBox(height: 8),
                TextFormField(
                  controller: viewModel.selectedSchedule,
                  readOnly: true,
                  decoration: _buildInputDecoration(
                    hint: AppStrings.get('selectScheduleHint'),
                    icon: Icons.access_time,
                  ),
                ),
                const SizedBox(height: 20),

                // Campo Unidad
                _buildLabel(AppStrings.get('unitLabel')),
                const SizedBox(height: 8),
                TextFormField(
                  controller: viewModel.unitController,
                  readOnly: true,
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
                  controller: viewModel.commentController,
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
                    onPressed: viewModel.isSubmitting
                        ? null
                        : () => viewModel.submitForm(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SuggestionsViewModel.primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: viewModel.isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.send, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                AppStrings.get('sendSuggestion'),
                                style: const TextStyle(
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
      prefixIcon: Icon(icon, color: SuggestionsViewModel.primaryOrange),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
        borderSide: const BorderSide(color: SuggestionsViewModel.primaryOrange, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}
