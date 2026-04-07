// lib/core/services/socket_service.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get/get.dart';

import '../main.dart';
import '../Network/NetworkServices.dart';
import '../Controller/orderController.dart';
import '../Controller/sellercontroller.dart';
import '../Controller/DashboardController.dart';
import '../Controller/adminController.dart';
import '../Services/PaymentService.dart';

class SocketService extends GetxService {
  static SocketService get to => Get.find();

  IO.Socket? _socket;

  // Make these public by removing underscore or providing getters
  final RxBool isConnected = false.obs;
  final RxString connectionStatus = 'disconnected'.obs;
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  // Private property for internal use only

  // Getter for unread count
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  // Stream controllers
  final StreamController<NotificationModel> _notificationStreamController =
      StreamController<NotificationModel>.broadcast();

  Stream<NotificationModel> get notificationStream =>
      _notificationStreamController.stream;

  // Server URL
  String get _serverUrl => NetworkServices.socketUrl;

  @override
  void onInit() {
    super.onInit();
    connect(token);
  }

  @override
  void onClose() {
    disconnect();
    _notificationStreamController.close();
    super.onClose();
  }

  // Connect to socket server
  Future<void> connect(String token) async {
    try {
      print('inside socket connect');
      if (_socket != null && _socket!.connected) {
        disconnect();
      }

      connectionStatus.value = 'connecting';

      _socket = IO.io(
        _serverUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .setTimeout(10000)
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setReconnectionAttempts(5)
            .disableAutoConnect()
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .build(),
      );

      _setupEventListeners();

      _socket!.onConnect((_) {
        print('Socket connected');
        connectionStatus.value = 'authenticating';
        _authenticate(token);
      });

      _socket!.connect();
    } catch (error) {
      print('Socket connection error: $error');
      connectionStatus.value = 'error';
      Get.snackbar(
        'Connection Error',
        'Failed to connect to server',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // Authenticate with server
  void _authenticate(String token) {
    _socket!.emit('authenticate', token);
  }

  // Setup event listeners
  void _setupEventListeners() {
    _socket!.on('authenticated', (data) {
      print('✅ Socket authenticated: $data');
      isConnected.value = true;
      connectionStatus.value = 'connected';

      // Join admin room if user is admin
      if (data['role'] == 'admin') {
        joinAdminNotifications();
      }

      Get.snackbar(
        'Connected',
        'Real-time notifications enabled',
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
      );
    });

    _socket!.on('auth_error', (data) {
      print('❌ Authentication error: $data');
      connectionStatus.value = 'auth_error';
      Get.snackbar(
        'Authentication Failed',
        'Please login again',
        snackPosition: SnackPosition.TOP,
      );
    });

    // Admin notification events
    _socket!.on('new_seller_registration', _handleNewSeller);
    _socket!.on('new_order_placed', _handleNewOrder);
    _socket!.on('order_status_changed', _handleOrderStatus);

    // New events requested
    _socket!.on('order_status_update', _handleOrderStatusUpdate);
    _socket!.on('new_notification', _handleNewNotification);
    _socket!.on('new_order_received', _handleNewOrderReceived);

    _socket!.on('connect_error', (error) {
      print('Socket connection error: $error');
      connectionStatus.value = 'error';
    });

    _socket!.on('disconnect', (reason) {
      print('Socket disconnected: $reason');
      isConnected.value = false;
      connectionStatus.value = 'disconnected';
    });
  }

  // Helper to refresh all data silently
  void _refreshAllData() {
    print('🔄 Refreshing all admin data silently...');

    // 1. Refresh Orders
    try {
      if (Get.isRegistered<OrdersController>()) {
        Get.find<OrdersController>().fetchOrders(silent: true);
      }
    } catch (e) {
      print('Error refreshing orders: $e');
    }

    // 2. Refresh Sellers
    try {
      if (Get.isRegistered<SellersController>()) {
        Get.find<SellersController>().fetchSellers(silent: true);
      }
    } catch (e) {
      print('Error refreshing sellers: $e');
    }

    // 3. Refresh Dashboard
    try {
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().fetchDashboardData(silent: true);
      }
    } catch (e) {
      print('Error refreshing dashboard: $e');
    }

    // 4. Refresh Payments
    try {
      if (Get.isRegistered<PaymentService>()) {
        Get.find<PaymentService>().fetchPayments();
      }
    } catch (e) {
      print('Error refreshing payments: $e');
    }

    // 5. Refresh Admin Badge (Direct)
    try {
      if (Get.isRegistered<AdminController>()) {
        Get.find<AdminController>().fetchPendingSellerCount();
      }
    } catch (e) {
      print('Error refreshing admin badges: $e');
    }
  }

  // Handle new seller registration
  void _handleNewSeller(dynamic data) {
    print('📢 New seller registration: $data');

    _refreshAllData();

    final notification = NotificationModel(
      id: 'seller_${data['sellerId']}_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.newSeller,
      title: 'New Seller Registration',
      message: data['message'] ?? 'A new seller has registered',
      data: data,
      timestamp: DateTime.now(),
      isRead: false,
    );

    _addNotification(notification);
    _showTopLevelSnackbar(
      notification.title,
      notification.message,
      color: Colors.green,
    );
  }

  // Handle new order placed
  void _handleNewOrder(dynamic data) {
    print('🛒 New order placed: $data');

    _refreshAllData();

    final notification = NotificationModel(
      id: 'order_${data['orderId']}_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.newOrder,
      title: 'New Order Placed',
      message: data['message'] ?? 'A new order has been placed',
      data: data,
      timestamp: DateTime.now(),
      isRead: false,
    );

    _addNotification(notification);
  }

  // Handle existing order status changed event
  void _handleOrderStatus(dynamic data) {
    print('📊 Order status changed: $data');

    _refreshAllData();

    // 3. Customize Color/Icon based on Status
    Color notifColor = Colors.blue;
    IconData notifIcon = Icons.update;
    String status = data['newStatus'] ?? '';

    switch (status.toLowerCase()) {
      case 'completed':
        notifColor = Colors.green;
        notifIcon = Icons.check_circle;
        break;
      case 'in_transit':
        notifColor = Colors.orange;
        notifIcon = Icons.local_shipping;
        break;
      case 'return_requested':
        notifColor = Colors.redAccent;
        notifIcon = Icons.refresh;
        break;
      case 'pickup_ready':
      case 'assigned':
        notifColor = Colors.indigo;
        notifIcon = Icons.local_shipping_outlined;
        break;
      case 'delivered':
      case 'empty_return':
        notifColor = Colors.teal;
        notifIcon = Icons.inventory_2;
        break;
    }

    final notification = NotificationModel(
      id: 'status_${data['orderId']}_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.orderStatus,
      title: data['title'] ?? 'Order Status Updated',
      message:
          data['message'] ??
          'Order # ${data['orderNumber']} changed to $status',
      data: data,
      timestamp: DateTime.now(),
      isRead: false,
    );

    _addNotification(notification);

    // Show a "Great" Snackbar
    Get.snackbar(
      notification.title,
      notification.message,
      backgroundColor: notifColor.withOpacity(0.9),
      colorText: Colors.white,
      icon: Icon(notifIcon, color: Colors.white),
      duration: Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  // Handle order status update (New requested event) - Consolidating logic
  void _handleOrderStatusUpdate(dynamic data) {
    // Delegate to the main handler as logic is identical for now
    _handleOrderStatus(data);
  }

  // Handle new notification (New requested event)
  void _handleNewNotification(dynamic data) {
    print('🔔 General notification received: $data');

    _refreshAllData();

    final notification = NotificationModel(
      id: 'gen_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.general,
      title: data['title'] ?? 'New Notification',
      message: data['message'] ?? 'You have a new message',
      data: data,
      timestamp: DateTime.now(),
      isRead: false,
    );

    _addNotification(notification);
    _showTopLevelSnackbar(notification.title, notification.message);
  }

  // Handle new order received (New requested event)
  void _handleNewOrderReceived(dynamic data) {
    print('🛒 New order received event: $data');

    _refreshAllData();

    final notification = NotificationModel(
      id: 'new_ord_${data['orderId']}_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.newOrder,
      title: 'New Order Received!',
      message: data['message'] ?? 'You have a new order to process',
      data: data,
      timestamp: DateTime.now(),
      isRead: false,
    );

    _addNotification(notification);

    Get.defaultDialog(
      title: "New Order",
      middleText: notification.message,
      textConfirm: "View Orders",
      onConfirm: () {
        Get.back();
      },
    );
    _showTopLevelSnackbar(
      notification.title,
      notification.message,
      color: Colors.orange,
    );
  }

  void _showTopLevelSnackbar(
    String title,
    String message, {
    Color color = Colors.blue,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: color.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.notifications_active, color: Colors.white),
      duration: const Duration(seconds: 4),
    );
  }

  // Add notification to list
  void _addNotification(NotificationModel notification) {
    notifications.insert(0, notification);
    _notificationStreamController.add(notification);
  }

  // Join admin notifications room
  void joinAdminNotifications() {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('join_admin_notifications');
      print('👨‍💼 Joined admin notifications room');
    }
  }

  // Mark notification as read
  void markAsRead(String notificationId) {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      notifications[index].isRead = true;
      notifications.refresh();
    }
  }

  // Mark all as read
  void markAllAsRead() {
    for (var notification in notifications) {
      notification.isRead = true;
    }
    notifications.refresh();
  }

  // Clear all notifications
  void clearNotifications() {
    notifications.clear();
  }

  // Disconnect socket
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      isConnected.value = false;
      connectionStatus.value = 'disconnected';
      print('🔌 Socket disconnected');
    }
  }
}

// Notification model
class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final dynamic data;
  final DateTime timestamp;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.data,
    required this.timestamp,
    this.isRead = false,
  });

  // Format time
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  // Get icon based on type
  IconData get icon {
    switch (type) {
      case NotificationType.newSeller:
        return Icons.person_add;
      case NotificationType.newOrder:
        return Icons.shopping_cart;
      case NotificationType.orderStatus:
        return Icons.update;
      case NotificationType.general:
        return Icons.notifications;
    }
  }

  // Get color based on type
  Color get color {
    switch (type) {
      case NotificationType.newSeller:
        return Colors.green;
      case NotificationType.newOrder:
        return Colors.orange;
      case NotificationType.orderStatus:
        return Colors.blue;
      case NotificationType.general:
        return Colors.purple;
    }
  }
}

enum NotificationType { newSeller, newOrder, orderStatus, general }
