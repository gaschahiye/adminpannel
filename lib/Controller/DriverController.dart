// controllers/drivers_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_responsive_admin_panel/Network/NetworkServices.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../Models/DriverModel.dart';
import '../Network/api_client.dart';
import 'package:http/http.dart' as http;

import 'adminController.dart';

class DriversController extends GetxController {
  final ApiClient api = ApiClient(http.Client());

  AdminController controller = Get.find();
  // Loading states
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Filter states
  var searchQuery = ''.obs;
  var selectedStatus = 'All Status'.obs;
  var selectedZone = 'All Zones'.obs;

  // API Data
  var driverResponse = Rx<DriverModel?>(null);
  var driversList = <Drivers>[].obs;

  // Stats
  var totalDriversCount = 0.obs;
  var onlineDriversCount = 0.obs;
  var offlineDriversCount = 0.obs;
  var busyDriversCount = 0.obs;

  // Filter options
  var statusOptions = ['All Status', 'Online', 'Offline'].obs;
  var zoneOptions = ['All Zones'].obs;

  // Available zones for assignment
  var availableZones = <String>[].obs;

  // Get filtered drivers
  List<Drivers> get filteredDrivers {
    if (driversList.isEmpty) return [];

    return driversList.where((driver) {
      // Search filter
      final matchesSearch =
          searchQuery.isEmpty ||
          driver.fullName!.toLowerCase().contains(searchQuery.toLowerCase()) ||
          driver.phoneNumber!.contains(searchQuery) ||
          driver.vehicleNumber!.toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          driver.cnic!.contains(searchQuery);

      // Status filter
      final matchesStatus =
          selectedStatus.value == 'All Status' ||
          (selectedStatus.value == 'Online' && driver.isActive == true) ||
          (selectedStatus.value == 'Offline' && driver.isActive == false);

      // Zone filter
      final matchesZone =
          selectedZone.value == 'All Zones' ||
          driver.zoneObject?.zoneName == selectedZone.value;

      return matchesSearch && matchesStatus && matchesZone;
    }).toList();
  }

  // Get driver by ID
  Drivers? getDriverById(String id) {
    try {
      return driversList.firstWhere((driver) => driver.sId == id);
    } catch (e) {
      return null;
    }
  }

  // Fetch drivers from API
  Future<void> fetchDrivers({int page = 1}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final url =
          '${NetworkServices.endpoint}/drivers?sortBy=createdAt&sortOrder=desc';
      debugPrint('Fetching drivers from: $url');
      final response = await api.getRequest(url);

      debugPrint('Drivers API Response Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Drivers API Response Body: ${jsonEncode(data)}');

        final driverModel = DriverModel.fromJson(data);

        if (driverModel.success == true) {
          driverResponse.value = driverModel;

          // Robust parsing: check nested data.drivers, top-level drivers, or top-level data as list
          if (driverModel.data?.drivers != null) {
            driversList.value = driverModel.data!.drivers!;
          } else if (data['drivers'] != null && data['drivers'] is List) {
            final List<dynamic> driversJson = data['drivers'];
            driversList.value =
                driversJson.map((json) => Drivers.fromJson(json)).toList();
          } else if (data['data'] != null && data['data'] is List) {
            final List<dynamic> driversJson = data['data'];
            driversList.value =
                driversJson.map((json) => Drivers.fromJson(json)).toList();
          } else {
            driversList.value = [];
          }

          // Debug snippet to check email parsing
          debugPrint('DEBUG DRIVER EMAILS:');
          for (var d in driversList) {
            debugPrint('Driver: ${d.fullName}, Email: ${d.email}');
          }

          debugPrint('Successfully loaded ${driversList.length} drivers');

          // Update stats
          _updateStats();
        } else {
          errorMessage.value =
              'Failed to load drivers data: ${data['message']}';
          debugPrint('API Error: ${data['message']}');
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
        debugPrint('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage.value = 'Failed to load drivers: $e';
      debugPrint('Error fetching drivers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle driver status
  Future<void> toggleDriverStatus(Drivers driver) async {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Change Status'),
        content: Text(
          'Are you sure you want to change ${driver.fullName}\'s status to ${driver.isActive == true ? 'Offline' : 'Online'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('No', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () async {
              Get.back(); // Close dialog
              try {
                isLoading.value = true;
                final newStatus = driver.isActive != true;
                final response = await api.postRequest(
                  '${NetworkServices.endpoint}/drivers/${driver.sId}/status',
                  body: {'isActive': newStatus},
                );

                if (response.statusCode == 200) {
                  await fetchDrivers();
                  Get.snackbar(
                    'Success',
                    'Driver status updated',
                    backgroundColor: Color(0xFFDCFCE7),
                    colorText: Color(0xFF166534),
                    icon: Icon(Iconsax.tick_circle, color: Color(0xFF166534)),
                  );
                }
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to update driver status: $e',
                  backgroundColor: Color(0xFFFEF2F2),
                  colorText: Color(0xFF991B1B),
                );
              } finally {
                isLoading.value = false;
              }
            },
            child: Text('Yes', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Delete driver
  Future<void> deleteDriver(String driverId) async {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Delete Driver'),
        content: Text(
          'Are you sure you want to delete this driver? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Get.back(); // Close dialog
              try {
                isLoading.value = true;
                final response = await api.deleteRequest(
                  '${NetworkServices.endpoint}/drivers/$driverId',
                );

                if (response.statusCode == 200) {
                  await fetchDrivers();
                  Get.snackbar(
                    'Success',
                    'Driver deleted successfully',
                    backgroundColor: Color(0xFFDCFCE7),
                    colorText: Color(0xFF166534),
                    icon: Icon(Iconsax.tick_circle, color: Color(0xFF166534)),
                  );
                }
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to delete driver: $e',
                  backgroundColor: Color(0xFFFEF2F2),
                  colorText: Color(0xFF991B1B),
                );
              } finally {
                isLoading.value = false;
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Add new driver
  Future<void> addDriver({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
    required String cnic,
    required String vehicleNumber,
    required Map<String, dynamic> zone,
    required String licencenumber,
    bool autoAssignOrders = true,
  }) async {
    try {
      isLoading.value = true;

      final response = await api.postRequest(
        '${NetworkServices.endpoint}/drivers/add',
        body: {
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'email': email,
          'password': password,
          'cnic': cnic,
          'vehicleNumber': vehicleNumber,
          'zone': zone,
          'autoAssignOrders': autoAssignOrders,
          'licenseNumber': licencenumber,
        },
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Refresh drivers list
          await fetchDrivers();

          controller.cancelAddDriver();
          Get.snackbar(
            'Success',
            'Driver added successfully',
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
          throw Exception(data['message'] ?? 'Failed to add driver');
        }
      } else {
        throw Exception('Failed to add driver: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add driver: $e',
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

  // Update driver information
  Future<void> updateDriver({
    required String driverId,
    required String fullName,
    required String phoneNumber,
    required String email,
    required String cnic,
    required String vehicleNumber,
    required Map<String, dynamic> zone,
    bool? autoAssignOrders,
  }) async {
    try {
      isLoading.value = true;

      final updateData = {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'email': email,
        'cnic': cnic,
        'vehicleNumber': vehicleNumber,
        'zone': zone,
      };

      if (autoAssignOrders != null) {
        updateData['autoAssignOrders'] = autoAssignOrders;
      }

      final response = await api.putRequest(
        '${NetworkServices.endpoint}/drivers/$driverId',
        body: updateData,
      );

      if (response.statusCode == 200) {
        await fetchDrivers();
        Get.snackbar(
          'Success',
          'Driver updated successfully',
          backgroundColor: Color(0xFFDCFCE7),
          colorText: Color(0xFF166534),
          icon: Icon(Iconsax.tick_circle, color: Color(0xFF166534)),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update driver: $e',
        backgroundColor: Color(0xFFFEF2F2),
        colorText: Color(0xFF991B1B),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get driver stats color
  Color getStatusColor(bool? isActive) {
    return isActive == true ? Colors.green : Colors.red;
  }

  // Get driver status icon
  IconData getStatusIcon(bool? isActive) {
    return isActive == true ? Icons.check_circle : Icons.cancel;
  }

  // Format date
  String formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  // Helper to update stats
  void _updateStats() {
    totalDriversCount.value = driversList.length;
    onlineDriversCount.value =
        driversList.where((d) => d.isActive == true).length;
    offlineDriversCount.value =
        driversList.where((d) => d.isActive == false).length;
    busyDriversCount.value =
        driversList
            .where((d) => d.driverStatus?.toLowerCase() == 'busy')
            .length;

    debugPrint(
      'Updated Driver Stats: Total=${totalDriversCount.value}, Online=${onlineDriversCount.value}, Offline=${offlineDriversCount.value}, Busy=${busyDriversCount.value}',
    );
  }

  @override
  void onInit() {
    super.onInit();
    // _loadMockData();
    fetchDrivers();
  }

  @override
  void onClose() {
    api.close();
    super.onClose();
  }
}
