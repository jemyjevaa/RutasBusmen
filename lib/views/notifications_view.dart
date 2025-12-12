import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/ResponseServ.dart';
import '../viewModel/notification/NotificationViewModel.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  static const Color primaryOrange = Color(0xFFFF6B35);

  // Lista de notificaciones de ejemplo
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  // final List<Map<String, dynamic>> _notifications = [
  //   {
  //     'title': 'Ruta actualizada',
  //     'message': 'La ruta ALBROOK ha cambiado su horario',
  //     'time': 'Hace 5 min',
  //     'icon': Icons.directions_bus,
  //     'isRead': false,
  //   },
  //   {
  //     'title': 'Parada cercana',
  //     'message': 'Estás a 200m de tu parada',
  //     'time': 'Hace 15 min',
  //     'icon': Icons.location_on,
  //     'isRead': false,
  //   },
  //   {
  //     'title': 'Retraso en servicio',
  //     'message': 'El autobús PANAMA OESTE tiene un retraso de 10 minutos',
  //     'time': 'Hace 1 hora',
  //     'icon': Icons.warning,
  //     'isRead': true,
  //   },
  //   {
  //     'title': 'Nueva ruta disponible',
  //     'message': 'Ruta ALBROOK para llegar a tu destino',
  //     'time': 'Hace 2 horas',
  //     'icon': Icons.add_road,
  //     'isRead': true,
  //   },
  // ];

  @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Notificaciones'),
  //       backgroundColor: Colors.white,
  //       elevation: 0,
  //       iconTheme: const IconThemeData(color: Colors.black),
  //       titleTextStyle: const TextStyle(
  //         color: Colors.black,
  //         fontSize: 20,
  //         fontWeight: FontWeight.bold,
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             setState(() {
  //               for (var notification in _notifications) {
  //                 notification['isRead'] = true;
  //               }
  //             });
  //           },
  //           child: const Text(
  //             'Marcar todas',
  //             style: TextStyle(color: primaryOrange),
  //           ),
  //         ),
  //       ],
  //     ),
  //     body: _notifications.isEmpty
  //         ? _buildEmptyState()
  //         : ListView.builder(
  //             padding: const EdgeInsets.all(16),
  //             itemCount: _notifications.length,
  //             itemBuilder: (context, index) {
  //               return _buildNotificationCard(_notifications[index], index);
  //             },
  //           ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = NotificationsViewModel();
        vm.loadNotifications();  // carga los datos cuando se crea el VM
        return vm;
      },
      child: Consumer<NotificationsViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (vm.error != null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Notificaciones')),
              body: Center(child: Text('Error: ${vm.error}')),
            );
          }

          final notifications = vm.notifications;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Notificaciones'),
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
              titleTextStyle: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              actions: [
                TextButton(
                  onPressed: vm.markAllAsRead, // marca todas como leídas
                  child: const Text(
                    'Marcar todas',
                    style: TextStyle(color: Color(0xFFFF6B35)),
                  ),
                ),
              ],
            ),
            body: notifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                return Dismissible(
                  key: Key('notification_${n.id}'),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => vm.removeNotificationAt(index),
                  child: _buildNotificationCard(n , index),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes notificaciones',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
  //   final bool isRead = notification['isRead'] ?? false;
  //
  //   return Dismissible(
  //     key: Key('notification_$index'),
  //     direction: DismissDirection.endToStart,
  //     background: Container(
  //       alignment: Alignment.centerRight,
  //       padding: const EdgeInsets.only(right: 20),
  //       margin: const EdgeInsets.only(bottom: 12),
  //       decoration: BoxDecoration(
  //         color: Colors.red,
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: const Icon(
  //         Icons.delete,
  //         color: Colors.white,
  //         size: 28,
  //       ),
  //     ),
  //     onDismissed: (direction) {
  //       setState(() {
  //         _notifications.removeAt(index);
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Notificación eliminada')),
  //       );
  //     },
  //     child: Container(
  //       margin: const EdgeInsets.only(bottom: 12),
  //       decoration: BoxDecoration(
  //         color: isRead ? Colors.white : primaryOrange.withOpacity(0.05),
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(
  //           color: isRead ? Colors.grey[300]! : primaryOrange.withOpacity(0.3),
  //           width: 1,
  //         ),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.grey.withOpacity(0.1),
  //             blurRadius: 4,
  //             offset: const Offset(0, 2),
  //           ),
  //         ],
  //       ),
  //       child: ListTile(
  //         contentPadding: const EdgeInsets.all(16),
  //         leading: Container(
  //           padding: const EdgeInsets.all(12),
  //           decoration: BoxDecoration(
  //             color: primaryOrange.withOpacity(0.1),
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           child: Icon(
  //             notification['icon'],
  //             color: primaryOrange,
  //             size: 28,
  //           ),
  //         ),
  //         title: Text(
  //           notification['title'],
  //           style: TextStyle(
  //             fontSize: 16,
  //             fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
  //             color: Colors.black87,
  //           ),
  //         ),
  //         subtitle: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             const SizedBox(height: 4),
  //             Text(
  //               notification['message'],
  //               style: TextStyle(
  //                 fontSize: 14,
  //                 color: Colors.grey[700],
  //               ),
  //             ),
  //             const SizedBox(height: 8),
  //             Text(
  //               notification['time'],
  //               style: TextStyle(
  //                 fontSize: 12,
  //                 color: Colors.grey[500],
  //               ),
  //             ),
  //           ],
  //         ),
  //         trailing: !isRead
  //             ? Container(
  //                 width: 10,
  //                 height: 10,
  //                 decoration: const BoxDecoration(
  //                   color: primaryOrange,
  //                   shape: BoxShape.circle,
  //                 ),
  //               )
  //             : null,
  //         onTap: () {
  //           setState(() {
  //             notification['isRead'] = true;
  //           });
  //         },
  //       ),
  //     ),
  //   );
  // }

  Widget _buildNotificationCard(NotificationItem item, int index) {
    return Dismissible(
      key: Key('notification_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      onDismissed: (_) {
        setState(() {
          _notifications.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notificación eliminada')),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : primaryOrange.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isRead
                ? Colors.grey[300]!
                : primaryOrange.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.notifications, color: primaryOrange, size: 28),
          ),
          title: Text(
            item.titulo,
            style: TextStyle(
              fontSize: 16,
              fontWeight: item.isRead ? FontWeight.w500 : FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                item.notificacion,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.fecha,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          trailing: item.isRead
              ? null
              : Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: primaryOrange,
              shape: BoxShape.circle,
            ),
          ),
          onTap: () {
            setState(() {
              item.isRead = true;
            });
          },
        ),
      ),
    );
  }


}
