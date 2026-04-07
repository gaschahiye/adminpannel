// admin/controllers/dashboard_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../Models/DashboardModel.dart';
import '../Network/NetworkServices.dart';
import '../Network/api_client.dart';

// Import your model (assuming it's in the same directory)

class DashboardController extends GetxController {
  final ApiClient api = ApiClient(http.Client());

  // Observable data
  Rx<DashboardModel> dashboardData = DashboardModel().obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  // Convenience getters
  Stats? get stats => dashboardData.value.stats;
  int get totalSellers => stats?.totalSellers ?? 0;
  int get totalOrders => stats?.totalOrders ?? 0;
  int get totalRevenue => stats?.totalRevenue ?? 0;
  int get activeDrivers => stats?.activeDrivers ?? 0;
  List<MonthlyOrderData> get monthlyOrderData => stats?.monthlyOrderData ?? [];
  List<OrderStatusData> get orderStatusData => stats?.orderStatusData ?? [];
  List<RecentNotifications> get recentNotifications =>
      stats?.recentNotifications ?? [];

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData({bool silent = false}) async {
    try {
      if (!silent) isLoading.value = true;
      errorMessage.value = '';
      update();
      final url = "${NetworkServices.endpoint}/dashboard/widgets";
      final response = await api.getRequest(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Dashboard data: ${data}');

        dashboardData.value = DashboardModel.fromJson(data);

        if (!dashboardData.value.success!) {
          errorMessage.value = 'Failed to load dashboard data';
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load dashboard data: $e';
      debugPrint('Error fetching dashboard: $e');
    } finally {
      if (!silent) isLoading.value = false;
      update();
    }
  }

  // Helper methods for formatting
  String formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String formatCurrency(int amount) {
    if (amount >= 1000) {
      return 'Rs.${(amount / 1000).toStringAsFixed(1)}K';
    }
    return 'Rs.$amount';
  }

  void refreshData() {
    fetchDashboardData();
  }
  @override
  void onClose() {
    api.close();
    super.onClose();
  }
}
