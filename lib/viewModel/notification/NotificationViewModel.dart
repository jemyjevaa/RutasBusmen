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

      print("=> ${response?.data}");

      // Supongamos que response contiene una lista en response.data
      // Debes adaptar según estructura real
      // final List<NotificationItem> items = response?.map((json) {
      //   return NotificationItem.fromJson(json);
      // }).toList();

      _notifications = [];
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
