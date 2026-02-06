import 'package:flutter/cupertino.dart';
import 'package:geovoy_app/services/RequestServ.dart';

import '../../services/ResponseServ.dart';
import '../../services/UserSession.dart';


import 'package:flutter/material.dart';

class NotificationsViewModel extends ChangeNotifier {
  final RequestServ _serv = RequestServ.instance;
  List<NotificationItem> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationItem> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadNotifications() async {

    _isLoading = true;
    notifyListeners();

    try {
      final session = UserSession();
      Empresa? company = session.getCompanyData();

      final response = await _serv.handlingRequestParsed<ApiResNotification>(
        urlParam: RequestServ.urlNotification,
        params: {'empresa': company!.clave},
        method: 'POST',
        asJson: true,
        fromJson: (json) => ApiResNotification.fromJson(json),
      );

      // Debes adaptar según estructura real
      final List<NotificationItem> items = response?.data ?? [];

      _notifications = items;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _notifications = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void removeNotificationAt(int index) {
    _notifications.removeAt(index);
    notifyListeners();
  }

  void markAsRead(int index) {
    _notifications[index].isRead = true;
    notifyListeners();
  }

}


/*
* whole => entero / completo
* wise => sabio / prudente
* there's => hay / hay algo
* through => a través de / a través
* something's about to break through => algo se va a romper a través de
* gonna => voy a
* get => obtener
* barely => casi
* sink => flotar
* that team can barely sink cour isn't shaing => el equipo puede casi flotar pero no comparte
* finally => finalmente
* managed => gestionado
* */
