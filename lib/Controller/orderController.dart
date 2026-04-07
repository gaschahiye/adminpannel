// controllers/orders_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_responsive_admin_panel/Network/NetworkServices.dart';
import 'package:get/get.dart';

import '../Models/OrderModel.dart';
import 'package:http/http.dart' as http;

import '../Network/api_client.dart';

class OrdersController extends GetxController {
  final ApiClient api = ApiClient(http.Client());
  // Loading states
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Filter states
  var searchQuery = ''.obs;
  var selectedStatus = 'All Status'.obs;
  var selectedType = 'All Types'.obs;

  // API Data
  var ordersResponse = Rx<OrdersResponse?>(null);
  var ordersList = <Order>[].obs;

  // Filter options
  var statusOptions =
      ['All Status', 'pending', 'in_transit', 'completed', 'cancelled'].obs;
  var typeOptions = ['All Types', 'regular', 'urgent', 'scheduled'].obs;

  // Get filtered orders
  List<Order> get filteredOrders {
    if (ordersList.isEmpty) return [];

    return ordersList.where((order) {
      // Search filter
      final matchesSearch =
          searchQuery.isEmpty ||
          order.orderId.toLowerCase().contains(searchQuery.toLowerCase()) ||
          order.buyer.fullName.toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          order.buyer.phoneNumber.contains(searchQuery);

      // Status filter
      final matchesStatus =
          selectedStatus.value == 'All Status' ||
          order.status == selectedStatus.value;

      // Type filter
      final matchesType =
          selectedType.value == 'All Types' ||
          (selectedType.value == 'urgent' && order.isUrgent) ||
          (selectedType.value != 'urgent' &&
              order.orderType == selectedType.value);

      return matchesSearch && matchesStatus && matchesType;
    }).toList();
  }

  // Get order by ID
  Order? getOrderById(String id) {
    try {
      return ordersList.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  // Fetch orders from API
  Future<void> fetchOrders({int page = 1, bool silent = false}) async {
    try {
      if (!silent) isLoading.value = true;
      errorMessage.value = '';

      final response = await api.getRequest(
        '${NetworkServices.endpoint}/orders?page=$page&limit=2000000&sortBy=createdAt&sortOrder=desc',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Orders data: $data');
        final ordersResponse = OrdersResponse.fromJson(data);

        if (ordersResponse.success) {
          this.ordersResponse.value = ordersResponse;
          ordersList.value = ordersResponse.data.orders;
        } else {
          errorMessage.value = 'Failed to load orders data';
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load orders: $e';
      debugPrint('Error fetching orders: $e');
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String id, String status) async {
    try {
      isLoading.value = true;
      // Note: Endpoint might need adjustment based on actual API
      final url = "${NetworkServices.endpoint}/orders/$id/status";
      final response = await api.putRequest(url, body: {'status': status});

      if (response.statusCode == 200) {
        await fetchOrders();
        Get.snackbar(
          'Success',
          'Order status updated to $status',
          backgroundColor: Color(0xFFDCFCE7), // Emerald 100
          colorText: Color(0xFF166534), // Emerald 800
          icon: Icon(Icons.check_circle, color: Color(0xFF166534)),
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.all(16),
          borderRadius: 8,
          boxShadows: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
          duration: Duration(seconds: 3),
        );
      } else {
        throw Exception('Failed to update status');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update order status: $e',
        backgroundColor: Color(0xFFFEF2F2), // Red 50
        colorText: Color(0xFF991B1B), // Red 800
        icon: Icon(Icons.warning_amber_rounded, color: Color(0xFF991B1B)),
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(16),
        borderRadius: 8,
        boxShadows: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get status color
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Color(0xFFF59E0B); // Amber 500
      case 'in_transit':
      case 'in transit':
        return Color(0xFF3B82F6); // Blue 500
      case 'completed':
        return Color(0xFF10B981); // Emerald 500
      case 'cancelled':
        return Color(0xFFEF4444); // Red 500
      default:
        return Color(0xFF9CA3AF); // Gray 400
    }
  }

  // Get type color
  Color getTypeColor(String type, bool isUrgent) {
    if (isUrgent) return Color(0xFFDC2626); // Red 600
    switch (type.toLowerCase()) {
      case 'urgent':
        return Color(0xFFDC2626); // Red 600
      case 'scheduled':
        return Color(0xFF9333EA); // Purple 600
      case 'regular':
        return Color(0xFF2563EB); // Blue 600
      default:
        return Color(0xFF4B5563); // Gray 600
    }
  }

  @override
  void onInit() {
    super.onInit();
    // _loadMockData(); // Keep commented out
    fetchOrders();
  }
  @override
  void onClose() {
    api.close();
    super.onClose();
  }
}
