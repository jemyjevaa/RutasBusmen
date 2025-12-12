import 'package:flutter/cupertino.dart';

import '../../models/route_model.dart';
import '../../services/RequestServ.dart';
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

  final serv = RequestServ.instance;
  final session = UserSession();
  late Empresa? company = session.getCompanyData();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    shiftController.dispose();
    unitController.dispose();
    super.dispose();
  }

  Future<void> setRoute(RouteData? route) async {

    selectedRoute = route;
    setShift(route!.turnoRuta);

    try{


      ApiResUnitAssignedRoute? response = await serv.handlingRequestParsed<ApiResUnitAssignedRoute>(
        urlParam: RequestServ.urlUnitAssignedRoute,
        params: {'empresa': company!.clave, 'claveRuta': route!.claveRuta},
        method: 'POST',
        asJson: true,
        fromJson: (json) => ApiResUnitAssignedRoute.fromJson(json),
      );

      setUnit(response!.data[0].clave);
    }catch( excep ){
      print("excep => ${excep}");
    }finally{
      notifyListeners();
    }
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


  Future<void> submitForm( BuildContext context ) async {
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

      // final session = UserSession();
      // Empresa? company = session.getCompanyData();

      final serv = RequestServ.instance;
      try{

        await serv.handlingRequestParsed<ApiResSurvey>(
          urlParam: RequestServ.urlSurvey,
          params: {
            'actitud': validateQuest(operator),
            'limpieza': validateQuest(unitClean),
            'empresa': company?.clave,
            'coduccion': validateQuest(operatorDriver),
            'correo': emailController.text,
            'ruta': selectedRoute!.nombreRuta,
            'turno': shiftController.text,
            'unidad': unitController.text,
            'nombre_usuario': nameController.text,
          },
          method: 'POST',
          asJson: true,
          fromJson: (json) => ApiResSurvey.fromJson(json),
        );

        AnimatedResultDialog.showSuccess(
          context,
          title: 'Success',
          message: AppStrings.get('suggestionSent'),
        );
        clearForm();
      }catch( excep ){
        print("excep => ${excep}");
      }finally{
        notifyListeners();
      }

    }
  }

  String validateQuest(int val) {
    return switch (val) {
      1 => "Mala",
      5 => "Buena",
      _ => "Regular"
    };
  }

  void clearForm(){
    nameController.clear();
    emailController.clear();
    shiftController.clear();
    unitController.clear();
    selectedRoute = null;
    unitClean = 0;
    operator = 0;
    operatorDriver = 0;
  }


}