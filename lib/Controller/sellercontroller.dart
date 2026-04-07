// admin/controllers/seller_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../Models/Sellermodel.dart';
import '../Network/NetworkServices.dart';
import 'package:flutter_responsive_admin_panel/Network/api_client.dart';

class SellersController extends GetxController {
  final ApiClient api = ApiClient(http.Client());

  // Observable states
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = 'All Status'.obs;

  final Rx<SellerModel> sellerModel = SellerModel().obs;

  final RxList<String> statusOptions =
      ['All Status', 'Approved', 'Pending', 'Rejected'].obs;

  // Get the sellers list from the model
  List<Sellers> get sellersList => sellerModel.value.sellers ?? [];

  // Get pagination info
  Pagination? get pagination => sellerModel.value.pagination;

  // Observable stats
  final RxInt _totalSellersCount = 0.obs;
  // Made public for AdminController to listen
  final RxInt pendingSellersCount = 0.obs;
  final RxInt _approvedSellersCount = 0.obs;
  final RxInt _rejectedSellersCount = 0.obs;

  // Statistics getters
  int get totalSellers => _totalSellersCount.value;
  int get pendingCount => pendingSellersCount.value;
  int get approvedCount => _approvedSellersCount.value;
  int get rejectedCount => _rejectedSellersCount.value;

  // Filtered sellers based on search and status
  List<Sellers> get filteredSellers {
    return sellersList.where((seller) {
      final matchesSearch =
          searchQuery.value.isEmpty ||
          seller.businessName?.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ==
              true ||
          seller.phoneNumber?.contains(searchQuery.value) == true;

      final matchesStatus =
          selectedStatus.value == 'All Status' ||
          seller.sellerStatus?.toLowerCase() ==
              selectedStatus.value.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();
  }

  // Fetch sellers from API
  Future<void> fetchSellers({int page = 1, bool silent = false}) async {
    try {
      if (!silent) isLoading.value = true;
      errorMessage.value = '';

      // Main list fetch
      final url = "${NetworkServices.endpoint}/sellers?page=$page";
      final response = await api.getRequest(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        sellerModel.value = SellerModel.fromJson(data);

        if (sellerModel.value.success != true) {
          errorMessage.value = 'Failed to load sellers data';
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }

      // Fetch stats in background
      fetchSellerStats();
    } catch (e) {
      errorMessage.value = 'Failed to load sellers: $e';
      debugPrint('Error fetching sellers: $e');
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  // Fetch stats for all categories
  Future<void> fetchSellerStats() async {
    try {
      // Create futures for each status count
      // We use limit=1 because we only care about the totalSellers count in pagination
      final Future<int> totalFuture = _fetchCount(status: '');
      final Future<int> pendingFuture = _fetchCount(status: 'pending');
      final Future<int> approvedFuture = _fetchCount(status: 'approved');
      final Future<int> rejectedFuture = _fetchCount(status: 'rejected');

      final results = await Future.wait([
        totalFuture,
        pendingFuture,
        approvedFuture,
        rejectedFuture,
      ]);

      _totalSellersCount.value = results[0];
      pendingSellersCount.value = results[1];
      _approvedSellersCount.value = results[2];
      _rejectedSellersCount.value = results[3];
    } catch (e) {
      debugPrint('Error fetching seller stats: $e');
    }
  }

  Future<int> _fetchCount({required String status}) async {
    try {
      String url = "${NetworkServices.endpoint}/sellers?limit=1";
      if (status.isNotEmpty) {
        url += "&status=$status";
      }

      final response = await api.getRequest(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final model = SellerModel.fromJson(data);
        return model.pagination?.totalSellers ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // Get seller by ID
  Sellers? getSellerById(String id) {
    try {
      return sellersList.firstWhere((seller) => seller.sId == id);
    } catch (e) {
      return null;
    }
  }

  // Update seller status
  Future<void> updateSellerStatus(String id, String status) async {
    try {
      isLoading.value = true;
      final url = "${NetworkServices.endpoint}/sellers/$id/status";
      final response = await api.patchRequest(
        url,
        body: {'status': status, "notes": "Documents verified successfully."},
      );

      if (response.statusCode == 200) {
        // Refresh everything to ensure consistency
        await fetchSellers();

        Get.snackbar(
          'Success',
          'Seller status updated to $status',
          backgroundColor: Color(0xFFDCFCE7), // Emerald 100
          colorText: Color(0xFF166534), // Emerald 800
          icon: Icon(Iconsax.tick_circle, color: Color(0xFF166534)),
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
        'Failed to update seller status: $e',
        backgroundColor: Color(0xFFFEF2F2), // Red 50
        colorText: Color(0xFF991B1B), // Red 800
        icon: Icon(Iconsax.warning_2, color: Color(0xFF991B1B)),
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

  // Delete seller
  Future<void> deleteSeller(String id) async {
    try {
      isLoading.value = true;

      final url = "${NetworkServices.endpoint}/sellers/$id";
      final response = await api.deleteRequest(url);

      if (response.statusCode == 200) {
        // Refresh everything
        await fetchSellers();

        Get.snackbar(
          'Success',
          'Seller deleted successfully',
          backgroundColor: Color(0xFFDCFCE7), // Emerald 100
          colorText: Color(0xFF166534), // Emerald 800
          icon: Icon(Iconsax.tick_circle, color: Color(0xFF166534)),
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.all(16),
          borderRadius: 8,
          boxShadows: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
          duration: Duration(seconds: 3),
        );
      } else {
        throw Exception('Failed to delete seller');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete seller: $e',
        backgroundColor: Color(0xFFFEF2F2), // Red 50
        colorText: Color(0xFF991B1B), // Red 800
        icon: Icon(Iconsax.warning_2, color: Color(0xFF991B1B)),
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

  // Helper to get location string
  String getLocationString(Sellers seller) {
    if (seller.locations?.isNotEmpty == true) {
      final location = seller.locations!.first;
      return '${location.city ?? ''}, ${location.address ?? ''}'.trim();
    }
    return 'Location not specified';
  }

  // Helper to format date
  String formatDate(String? date) {
    if (date == null) return 'N/A';

    try {
      final parsedDate = DateTime.parse(date);
      return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
    } catch (e) {
      return date;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchSellers();
  }
  @override
  void onClose() {
    api.close();
    super.onClose();
  }
}
