// admin/controllers/seller_details_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../Models/SingleSellerModel.dart'
    show
        SellerResponse,
        Seller,
        Rating,
        SellerStats,
        SellerLocation,
        Cylinder,
        AddOn,
        Inventory;

import '../Network/NetworkServices.dart';
import '../Network/api_client.dart';

class SellerDetailsController extends GetxController {
  final ApiClient api = ApiClient(http.Client());

  // Observable states
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final Rx<SellerResponse> sellerDetails =
      SellerResponse(success: false, seller: null).obs;

  // Getter for current seller
  Seller? get seller => sellerDetails.value.seller;

  // Fetch seller details by ID
  Future<void> fetchSellerDetails(String sellerId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // API for detailed seller info
      final url = "${NetworkServices.endpoint}/sellers/$sellerId";
      final response = await api.getRequest(url);
      print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Seller details API response: ${data}');

        sellerDetails.value = SellerResponse.fromJson(data);

        if (!sellerDetails.value.success) {
          errorMessage.value = 'Failed to load seller details';
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load seller details: $e';
      debugPrint('Error fetching seller details: $e');

      // Clear error message if we are going to show mock data
      // so the screen doesn't stay on the error view.
      // Alternatively, keep it but allow mock data to show.
      // errorMessage.value = ''; // Uncommenting this would hide the error if mock data exists

      // Mock data for testing - remove in production
      await _loadMockSellerDetails(sellerId);
    } finally {
      isLoading.value = false;
    }
  }

  // Update seller status
  Future<void> updateSellerStatus(String status) async {
    try {
      if (seller == null) return;

      isLoading.value = true;

      // API call to update status
      final url = "${NetworkServices.endpoint}/sellers/${seller!.id}/status";
      final response = await api.postRequest(
        url,
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        // Update local seller
        final updatedSeller = Seller(
          id: seller!.id,
          role: seller!.role,
          phoneNumber: seller!.phoneNumber,
          orgaLicenseFile: seller!.orgaLicenseFile,
          isActive: seller!.isActive,
          isVerified: seller!.isVerified,
          language: seller!.language,
          businessName: seller!.businessName,
          orgaLicenseNumber: seller!.orgaLicenseNumber,
          orgaExpDate: seller!.orgaExpDate,
          ntnNumber: seller!.ntnNumber,
          sellerStatus: status, // Updated status
          autoAssignOrders: seller!.autoAssignOrders,
          driverStatus: seller!.driverStatus,
          createdAt: seller!.createdAt,
          updatedAt: DateTime.now(),
          rating: seller!.rating,
          stats: seller!.stats,
          locations: seller!.locations,
          inventory: seller!.inventory,
        );

        sellerDetails.value = SellerResponse(
          success: true,
          seller: updatedSeller,
        );

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

  // Load mock data for testing
  Future<void> _loadMockSellerDetails(String sellerId) async {
    await Future.delayed(Duration(seconds: 1));

    // Create mock detailed seller data
    sellerDetails.value = SellerResponse(
      success: true,
      seller: Seller(
        id: sellerId,
        role: 'seller',
        phoneNumber: '+1234567890',
        orgaLicenseFile: 'https://example.com/license.pdf',
        isActive: true,
        isVerified: true,
        language: 'en',
        businessName: 'Gas Delivery Co.',
        orgaLicenseNumber: 'LIC12345',
        orgaExpDate: DateTime.now().add(Duration(days: 365)),
        ntnNumber: 'NTN123456',
        sellerStatus: 'Approved',
        autoAssignOrders: true,
        driverStatus: 'active',
        createdAt: DateTime.now().subtract(Duration(days: 90)),
        updatedAt: DateTime.now(),
        rating: Rating(average: 4.5, count: 23),
        stats: SellerStats(
          totalOrders: 150,
          completedOrders: 145,
          totalRevenue: 45000.00,
          averageRating: 4.5,
          ratingCount: 23,
        ),
        locations: [
          SellerLocation(
            id: 'loc1',
            warehouseName: 'NY Warehouse',
            city: 'New York',
            address: '123 Main St',
            isActive: true,
            createdAt: DateTime.now().subtract(Duration(days: 60)),
            updatedAt: DateTime.now(),
          ),
          SellerLocation(
            id: 'loc2',
            warehouseName: 'Brooklyn Storage',
            city: 'Brooklyn',
            address: '456 Park Ave',
            isActive: true,
            createdAt: DateTime.now().subtract(Duration(days: 30)),
            updatedAt: DateTime.now(),
          ),
        ],
        inventory: [
          Inventory(
            id: 'inv1',
            location: 'Main Warehouse',
            city: 'New York',
            pricePerKg: 200,
            isRefund: true,
            totalInventory: 500,
            issuedCylinders: 150,
            isActive: true,
            createdAt: DateTime.now().subtract(Duration(days: 60)),
            updatedAt: DateTime.now(),
            cylinders: {
              '5kg': Cylinder(quantity: 200, price: 1000),
              '10kg': Cylinder(quantity: 150, price: 1800),
              '15kg': Cylinder(quantity: 100, price: 2500),
              '45kg': Cylinder(quantity: 50, price: 7000),
            },
            addOns: [
              AddOn(
                id: 'addon1',
                title: 'Regulator',
                price: 300,
                discount: 50,
                quantity: 100,
              ),
              AddOn(
                id: 'addon2',
                title: 'Safety Kit',
                price: 500,
                discount: 100,
                quantity: 50,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Clear seller details
  void clearDetails() {
    sellerDetails.value = SellerResponse(success: false, seller: null);
  }

  // Helper to format DateTime
  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper to get status color
  Color getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Color(0xFF10B981);
      case 'Pending':
        return Color(0xFFF59E0B);
      case 'Rejected':
        return Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }
}
