// admin/controllers/admin_controller.dart

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Network/NetworkServices.dart';
import 'package:flutter_responsive_admin_panel/Network/api_client.dart';
import '../Login/login.dart';
import 'sellercontroller.dart';
import '../Services/PaymentService.dart';

class AdminController extends GetxController {
  var currentIndex = 0.obs;
  var isSidebarExpanded = true.obs;
  var isAddingDriver = false.obs;
  var isViewingOrderDetails = false.obs;
  var isViewingSellerDetails = false.obs;
  var isViewingDriverDetails = false.obs;
  var selectedOrderId = ''.obs;
  var selectedSellerId = ''.obs;
  var selectedDriverId = ''.obs;

  // Notification Counts
  var sellerNotificationCount = 0.obs;
  var paymentNotificationCount = 0.obs;

  // Make menuItems reactive using RxList
  final RxList<Map<String, dynamic>> menuItems =
      <Map<String, dynamic>>[
        {'title': 'Dashboard', 'icon': Iconsax.element_4, 'notification': 0},
        {'title': 'Seller Management', 'icon': Iconsax.shop, 'notification': 0},
        {'title': 'Driver Management', 'icon': Iconsax.car, 'notification': 0},
        {'title': 'Order Management', 'icon': Iconsax.box, 'notification': 0},
        {
          'title': 'Payment Management',
          'icon': Iconsax.wallet_2,
          'notification': 0,
        },
        {'title': 'Logout', 'icon': Iconsax.logout, 'notification': 0},
      ].obs;

  final ApiClient api = ApiClient(http.Client());

  @override
  void onInit() {
    super.onInit();
    _setupNotificationListeners();
    _setupDataListeners();
    fetchPendingSellerCount(); // Initial fetch
  }

  void _setupDataListeners() {
    // Listen to Payment stats
    try {
      if (Get.isRegistered<PaymentService>()) {
        final paymentService = Get.find<PaymentService>();
        paymentService.statsStream.listen((stats) {
          paymentNotificationCount.value = stats.pendingCount;
        });
      }
    } catch (e) {
      print('Error setting up payment listeners: $e');
    }
  }

  Future<void> fetchPendingSellerCount() async {
    try {
      final url = "${NetworkServices.endpoint}/sellers?limit=1&status=pending";
      final response = await api.getRequest(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assuming the API returns pagination/metadata with total count
        // Based on SellersController logic: model.pagination?.totalSellers
        if (data['success'] == true && data['pagination'] != null) {
          final totalPending = data['pagination']['totalSellers'] ?? 0;
          sellerNotificationCount.value = totalPending;
        }
      }
    } catch (e) {
      print('Error fetching pending seller count: $e');
    }
  }

  void _setupNotificationListeners() {
    // Listen to changes in notification counts and update menu items
    ever(sellerNotificationCount, (count) {
      _updateMenuItemNotification('Seller Management', count);
    });

    ever(paymentNotificationCount, (count) {
      _updateMenuItemNotification('Payment Management', count);
    });
  }

  void _updateMenuItemNotification(String title, int count) {
    // Find index of the menu item
    final index = menuItems.indexWhere((item) => item['title'] == title);
    if (index != -1) {
      // Create a new map to trigger update (since maps are mutable but we need to notify Obx)
      final updatedItem = Map<String, dynamic>.from(menuItems[index]);
      updatedItem['notification'] = count;
      menuItems[index] = updatedItem;
    }
  }

  // Method to update seller count (can be called from socket or other controllers)
  void updateSellerCount(int count) {
    sellerNotificationCount.value = count;
  }

  // Method to update payment count
  void updatePaymentCount(int count) {
    paymentNotificationCount.value = count;
  }

  Future<void> changeTab(int index) async {
    // Logout is now index 5 (since we added Payments at index 4)
    if (index == 5) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');

      Get.offAll(() => AdminLoginScreen());
      return;
    }

    currentIndex.value = index;
    isAddingDriver.value = false;
    isViewingOrderDetails.value = false;
    isViewingSellerDetails.value = false;
    isViewingDriverDetails.value = false;
    selectedDriverId.value = '';
  }

  void toggleSidebar() {
    isSidebarExpanded.value = !isSidebarExpanded.value;
  }

  void showAddDriverForm() {
    currentIndex.value = 2;
    isAddingDriver.value = true;
    isViewingDriverDetails.value = false;
  }

  void cancelAddDriver() {
    isAddingDriver.value = false;
  }

  void showOrderDetails(String orderId) {
    currentIndex.value = 3;
    isViewingOrderDetails.value = true;
    selectedOrderId.value = orderId;
  }

  void hideOrderDetails() {
    isViewingOrderDetails.value = false;
    selectedOrderId.value = '';
  }

  void showSellerDetails(String sellerId) {
    currentIndex.value = 1;
    isViewingSellerDetails.value = true;
    selectedSellerId.value = sellerId;
  }

  void hideSellerDetails() {
    isViewingSellerDetails.value = false;
    selectedSellerId.value = '';
  }

  void showDriverDetails(String driverId) {
    currentIndex.value = 2;
    isViewingDriverDetails.value = true;
    isAddingDriver.value = false;
    selectedDriverId.value = driverId;
  }

  void hideDriverDetails() {
    isViewingDriverDetails.value = false;
    selectedDriverId.value = '';
  }
  @override
  void onClose() {
    api.close();
    super.onClose();
  }
}
