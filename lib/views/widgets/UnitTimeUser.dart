import 'package:flutter/cupertino.dart';

import '../../viewmodels/route_viewmodel.dart';

Widget timeUnitToUser(RouteViewModel vm){
  print("=> ${ vm.isUnitInRoute }");
  print("=> ${ vm.currentDestination.isNotEmpty }");
  bool isTime = vm.isUnitInRoute && vm.currentDestination.isNotEmpty;
  print("isTime => $isTime");
  return isTime?
  // Text("A ${vm.isUnitInRoute} min. de tu ubicación.")
  Text.rich(
      TextSpan(
        text: 'A :',
        children: <TextSpan>[
          TextSpan(text: "${vm.timeUnitUser} min.", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: ' de tu ubicación. ', style: TextStyle(fontStyle: FontStyle.italic)),
        ]
      )
  )
      :SizedBox.shrink();
}