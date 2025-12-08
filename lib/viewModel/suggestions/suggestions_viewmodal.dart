import 'package:flutter/material.dart';

import '../../models/route_model.dart';
import '../../utils/app_strings.dart';
import '../../widgets/animated_result_dialog.dart';

class SuggestionsViewModel extends ChangeNotifier {
  static const Color primaryOrange = Color(0xFFFF6B35);

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final unitController = TextEditingController();
  final commentController = TextEditingController();

  RouteData? selectedRoute;
  String? selectedSchedule;

  final schedules = [
    '06:00 - 08:00',
    '08:00 - 10:00',
    '10:00 - 12:00',
    '12:00 - 14:00',
    '14:00 - 16:00',
    '16:00 - 18:00',
    '18:00 - 20:00',
  ];

  void setRoute(RouteData? r) {
    selectedRoute = r;
    notifyListeners();
  }

  void setSchedule(String? s) {
    selectedSchedule = s;
    notifyListeners();
  }

  void submitForm(BuildContext context) {
    if (formKey.currentState!.validate()) {
      if (selectedRoute == null) {
        AnimatedResultDialog.showError(
          context,
          title: 'Error',
          message: AppStrings.get('routeError'),
        );
        return;
      }

      if (selectedSchedule == null) {
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
      );

      print("=> form:"
          "nameController : ${nameController.text},"
          "emailController : ${emailController.text},"
          "unitController : ${unitController.text},"
          "commentController : ${commentController.text},"
          "selectedRoute : ${selectedRoute},"
          "selectedSchedule : $selectedSchedule"
      );

      // Limpiar
      nameController.clear();
      emailController.clear();
      unitController.clear();
      commentController.clear();
      selectedRoute = null;
      selectedSchedule = null;

      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    unitController.dispose();
    commentController.dispose();
    super.dispose();
  }
}
