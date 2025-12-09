import 'package:flutter/material.dart';

import '../../models/route_model.dart';
import '../../services/RequestServ.dart';
import '../../services/ResponseServ.dart';
import '../../services/UserSession.dart';
import '../../utils/app_strings.dart';
import '../../widgets/animated_result_dialog.dart';

class SuggestionsViewModel extends ChangeNotifier {
  static const Color primaryOrange = Color(0xFFFF6B35);

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final unitController = TextEditingController();
  final commentController = TextEditingController();
  late final selectedSchedule = TextEditingController();


  RouteData? selectedRoute;
  // String? selectedSchedule;

  final serv = RequestServ.instance;
  final session = UserSession();
  late Empresa? company = session.getCompanyData();

  Future<void> setRoute(RouteData? r) async {
    selectedRoute = r;
    try{


      ApiResUnitAssignedRoute? response = await serv.handlingRequestParsed<ApiResUnitAssignedRoute>(
        urlParam: RequestServ.urlUnitAssignedRoute,
        params: {'empresa': company!.clave, 'claveRuta': r!.claveRuta},
        method: 'POST',
        asJson: true,
        fromJson: (json) => ApiResUnitAssignedRoute.fromJson(json),
      );
      unitController.text = response!.data[0].clave;
      setSchedule(r?.turnoRuta);
      // setUnit(response!.data[0].clave);
    }catch( excep ){
      print("excep => ${excep}");
    }finally{
      notifyListeners();
    }

  }

  void setSchedule(String? s) {
    selectedSchedule.text = s!;
    notifyListeners();
  }

  Future<void> submitForm(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      if (selectedRoute == null) {
        AnimatedResultDialog.showError(
          context,
          title: 'Error',
          message: AppStrings.get('routeError'),
        );
        return;
      }

      final serv = RequestServ.instance;
      try{

        ApiResSuggestion? response = await serv.handlingRequestParsed<ApiResSuggestion>(
          urlParam: RequestServ.urlSuggestion,
          params: {
            'comentario': commentController.text,
            'empresa': company?.clave,
            'correo': emailController.text,
            'ruta': selectedRoute!.nombreRuta,
            'turno': selectedSchedule.text,
            'unidad': unitController.text,
            'nombre_usuario': nameController.text,
          },
          method: 'POST',
          asJson: true,
          fromJson: (json) => ApiResSuggestion.fromJson(json),
        );

        AnimatedResultDialog.showSuccess(
          context,
          title: '¡Gracias!',
          message: response!.data,
        );
        clearForm();

      }catch( excep ){
        print("excep => ${excep}");
      }finally{
        notifyListeners();
      }




    }
  }

  void clearForm(){
    // Limpiar
    nameController.clear();
    emailController.clear();
    unitController.clear();
    commentController.clear();
    selectedSchedule.clear();
    selectedRoute = null;
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
