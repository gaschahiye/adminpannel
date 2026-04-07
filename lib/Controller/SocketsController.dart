// lib/core/controllers/socket_controller.dart
import 'package:get/get.dart';

import '../const/Sockets.dart';
import '../main.dart';
// Fixed import path

class SocketController extends GetxController {
  final SocketService socketService = SocketService.to;

  // Connection status
  RxBool get isConnected => socketService.isConnected;
  RxString get connectionStatus => socketService.connectionStatus;

  // Notifications
  RxList<NotificationModel> get notifications => socketService.notifications;
  int get unreadCount => socketService.unreadCount;

  // Connect to socket
  Future<void> connect(String token) async {
    await socketService.connect(token);
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    connect(token);
  }
  // Disconnect from socket
  void disconnect() {
    socketService.disconnect();
  }

  // Mark notification as read
  void markAsRead(String notificationId) {
    socketService.markAsRead(notificationId);
  }

  // Mark all notifications as read
  void markAllAsRead() {
    socketService.markAllAsRead();
  }

  // Clear all notifications
  void clearNotifications() {
    socketService.clearNotifications();
  }

  // Reconnect
  Future<void> reconnect(String token) async {
    disconnect();
    await Future.delayed(Duration(seconds: 1));
    await connect(token);
  }

  // Get notification stream
  Stream<NotificationModel> get notificationStream => socketService.notificationStream;

  // Check if socket is initialized
  bool get isSocketInitialized => socketService.isConnected.value;

  // Get current connection status
  String get currentStatus => socketService.connectionStatus.value;
}