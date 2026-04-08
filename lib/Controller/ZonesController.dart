// services/zones_service.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../Models/ZoneModel.dart';


class ZonesService extends GetxService {
  final Rx<CityZones?> cityZones = Rx<CityZones?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Selected zones for driver
  final RxList<Zone> selectedZones = <Zone>[].obs;

  Future<void> loadZones() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Load the JSON file from assets
      final String jsonString = await rootBundle.loadString('assets/ZonesJson/Zones.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      // Parse the zones data
      cityZones.value = CityZones.fromJson(jsonData);

      debugPrint('Loaded ${cityZones.value?.zones.length ?? 0} zones for ${cityZones.value?.city}');

    } catch (e) {
      errorMessage.value = 'Failed to load zones: $e';
      debugPrint('Error loading zones: $e');

      // Load mock data if file loading fails
      // await _loadMockZones();
    } finally {
      isLoading.value = false;
    }
  }

  // Future<void> _loadMockZones() async {
  //   cityZones.value = CityZones(
  //     city: 'Islamabad & Rawalpindi',
  //     note: 'Mock data for testing',
  //     zones: [
  //       Zone(
  //         zoneId: 'ZONE_A',
  //         zoneName: 'Central Islamabad (F & G Sectors)',
  //         description: 'This is the main and most populated area of Islamabad.',
  //         includedAreas: ['F-5', 'F-6', 'F-7'],
  //         centerPoint: CenterPoint(
  //           latitude: 33.7130,
  //           longitude: 73.0600,
  //           explanation: 'Central point',
  //         ),
  //         radiusKm: 10,
  //         radiusExplanation: '10 km radius',
  //         example: 'Example',
  //       ),
  //       Zone(
  //         zoneId: 'ZONE_B',
  //         zoneName: 'North & West Islamabad',
  //         description: 'This zone includes developing sectors.',
  //         includedAreas: ['D-12', 'D-13'],
  //         centerPoint: CenterPoint(
  //           latitude: 33.7600,
  //           longitude: 73.0300,
  //           explanation: 'North point',
  //         ),
  //         radiusKm: 10,
  //         radiusExplanation: '10 km radius',
  //         example: 'Example',
  //       ),
  //     ],
  //     importantNotesForBeginners: [],
  //   );
  // }

  // Get all zones
  List<Zone> get zones => cityZones.value?.zones ?? [];

  // Get zone by ID
  Zone? getZoneById(String zoneId) {
    return zones.firstWhereOrNull((zone) => zone.zoneId == zoneId);
  }

  // Get zone by name
  Zone? getZoneByName(String zoneName) {
    return zones.firstWhereOrNull((zone) => zone.zoneName == zoneName);
  }

  // Get all zone names
  List<String> getZoneNames() {
    return zones.map((zone) => zone.zoneName).toList();
  }

  // Check if zone is selected
  bool isZoneSelected(String zoneId) {
    return selectedZones.any((zone) => zone.zoneId == zoneId);
  }

  // Add zone to selected list
  void selectZone(Zone zone) {
    if (!isZoneSelected(zone.zoneId)) {
      selectedZones.add(zone);
    }
  }

  // Remove zone from selected list
  void removeZone(String zoneId) {
    selectedZones.removeWhere((zone) => zone.zoneId == zoneId);
  }

  // Clear all selected zones
  void clearSelectedZones() {
    selectedZones.clear();
  }

  // Get selected zone IDs for API submission
  List<String> getSelectedZoneIds() {
    return selectedZones.map((zone) => zone.zoneId).toList();
  }

  // Get selected zone names for display
  List<String> getSelectedZoneNames() {
    return selectedZones.map((zone) => zone.zoneName).toList();
  }

  // Get all areas from selected zones (unique)
  List<String> getAllSelectedAreas() {
    final allAreas = <String>[];
    for (final zone in selectedZones) {
      allAreas.addAll(zone.includedAreas);
    }
    return allAreas.toSet().toList()..sort();
  }

  @override
  void onInit() {
    super.onInit();
    loadZones();
  }
}