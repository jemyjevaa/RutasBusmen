import 'package:flutter/cupertino.dart';

import '../../models/route_model.dart';
import '../../services/ResponseServ.dart';
import '../../services/UserSession.dart';
import '../../utils/app_strings.dart';
import '../../widgets/animated_result_dialog.dart';

class SurveyViewModel extends ChangeNotifier{

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final shiftController = TextEditingController();
  final unitController = TextEditingController();

  RouteData? selectedRoute;

  int unitClean = 0;
  int operator = 0;
  int operatorDriver = 0;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void setRoute(RouteData? route){
    selectedRoute = route;
    notifyListeners();
  }

  void setUnitClean(int val){
    unitClean = val;
    notifyListeners();
  }

  void setOperator(int val){
    operator = val;
    notifyListeners();
  }

  void setOperatorDriver(int val) {
    operatorDriver = val;
    notifyListeners();
  }

  void setShift(String val){
    shiftController.text = val;
    notifyListeners();
  }

  void setUnit(String val){
    unitController.text = val;
    notifyListeners();
  }


  void submitForm( BuildContext context ){
    if(formKey.currentState!.validate()){

      if(selectedRoute == null){
        AnimatedResultDialog.showError(
          context,
          title: 'Error',
          message: AppStrings.get('routeError'),
        );
        return;
      }

      if(unitClean == 0 || operator == 0 || operatorDriver == 0){
        AnimatedResultDialog.showError(
          context,
          title: 'Error',
          message: AppStrings.get('fillAllFields'),
        );
        return;
      }

      final session = UserSession();
      Empresa? company = session.getCompanyData();

      Object things = {
        'actitud': validateQuest(operator),
        'limpieza': validateQuest(unitClean),
        'empresa': company!.clave,
        'coduccion': validateQuest(operatorDriver),
        'correo': emailController.text,
        'ruta': null,
        'turno': shiftController.text,
        'unidad': unitController.text,
        'nombre_usuario': nameController.text,
      };

      print(things);

      notifyListeners();
    }
  }

  String validateQuest(int val) {
    return switch (val) {
      1 => "Mala",
      5 => "Buena",
      _ => "Regular"
    };
  }


}