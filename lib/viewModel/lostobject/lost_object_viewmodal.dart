import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/route_model.dart';
import '../../utils/app_strings.dart';
import '../../widgets/animated_result_dialog.dart';

class LostObjectViewModal  extends ChangeNotifier{

  final formKey = GlobalKey<FormState>();
  final userController = TextEditingController();
  final phoneController = TextEditingController();
  final descriptionController = TextEditingController();

  RouteData? selectedRoute;
  DateTime? selectedDate;

  void setUser(String value){
    userController.text = value;
    notifyListeners();
  }

  void setPhone(String phone){
    phoneController.text = phone;
    notifyListeners();
  }

  void setDescription(String description){
    descriptionController.text = description;
    notifyListeners();
  }

  void setRoute(RouteData route){
    selectedRoute = route;
    notifyListeners();
  }

  void setDate(DateTime date){
    selectedDate = date;
    notifyListeners();
  }

  Future<void> selectDate(BuildContext context) async {
    const Color primaryOrange = Color(0xFFFF6B35);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
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
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
    }
  }

  void submitForm( BuildContext context ){
    if(formKey.currentState!.validate()){
      // if (selectedRoute == null) {
      //   AnimatedResultDialog.showError(
      //     context,
      //     title: 'Error',
      //     message: AppStrings.get('routeError'),
      //   );
      //   return;
      // }

      if (selectedDate == null) {
        AnimatedResultDialog.showError(
          context,
          title: 'Error',
          message: AppStrings.get('dateError'),
        );
        return;
      }

      print(
          "User: ${userController.text}\n"
              "Phone: ${phoneController.text}\n"
              "Description: ${descriptionController.text}\n"
              "Route: ${selectedRoute}\n"
              "Date: ${selectedDate!.toString()}"
      );

    }


  }

  @override
  void dispose() {
    userController.dispose();
    phoneController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

}