import 'package:flutter/cupertino.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalService {

  static const String _one_signal_id = "916e0af6-01b3-4331-ba47-089830d7de7f";

  Future<void> initOneSignal() async {
    try {
      debugPrint('initializing OneSignal');
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.initialize(_one_signal_id);
      await OneSignal.Notifications.requestPermission(true);
      // _setupOneSignalListeners();
    } catch (e) {
      debugPrint('Error initializing OneSignal: $e');
    }
  }

  Future<void> setOneSignalTags(String company, String userId) async {
    debugPrint('SETTING ONESIGNAL TAGS: empresaNombre=$company, empresasidusuario=$company-$userId');
    OneSignal.User.addTagWithKey("empresaNombre", company);
    // OneSignal.User.addTagWithKey("empresaidusuario", "$company-$userId");
  }

  Future<void> removeOneSignalTags() async {
    OneSignal.User.removeTags(["empresaNombre", "empresaidusuario"]);
  }

}