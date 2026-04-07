import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Models/payment_models.dart';
import '../Services/PaymentService.dart';

class PaymentController extends GetxController {
  final PaymentService _paymentService = Get.find<PaymentService>();

  // Observable states
  var payments = <PaymentTimelineEntry>[].obs;
  var stats = PaymentSummary().obs;
  var isLoading = false.obs;
  
  // Filter states
  var selectedStatus = 'all'.obs;
  var selectedType = 'all'.obs;
  var searchQuery = ''.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    _setupStreams();
    loadPayments();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  void _setupStreams() {
    // Sync local Rx variables with Service streams
    _paymentService.paymentsStream.listen((newPayments) {
      payments.value = newPayments;
    });

    _paymentService.statsStream.listen((newStats) {
      stats.value = newStats;
    });
  }

  Future<void> loadPayments() async {
    try {
      isLoading.value = true;
      await _paymentService.fetchPayments(
        status: selectedStatus.value,
        type: selectedType.value,
        searchQuery: searchQuery.value,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to load payments: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      loadPayments();
    });
  }

  void applyFilter({String? status, String? type}) {
    if (status != null) selectedStatus.value = status;
    if (type != null) selectedType.value = type;
    loadPayments();
  }

  Future<void> clearPayment(PaymentTimelineEntry payment, {String? referenceId, String? notes}) async {
    try {
      isLoading.value = true;
      await _paymentService.clearPayment(
        payment.id,
        referenceId: referenceId,
        notes: notes,
      );
      Get.snackbar('Success', 'Payment cleared successfully',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Clear failed: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> syncPayments() async {
    try {
      await _paymentService.syncPayments();
      Get.snackbar('Success', 'Payments synced with Google Sheet',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Sync failed: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> exportLedger() async {
     await _paymentService.exportPayments();
  }
}
