import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../Models/payment_models.dart';
import '../Network/NetworkServices.dart';
import '../Network/api_client.dart';

class PaymentService extends GetxService {
  final ApiClient _api = ApiClient(http.Client());

  final _paymentsController =
      StreamController<List<PaymentTimelineEntry>>.broadcast();
  final _statsController = StreamController<PaymentSummary>.broadcast();

  Stream<List<PaymentTimelineEntry>> get paymentsStream =>
      _paymentsController.stream;
  Stream<PaymentSummary> get statsStream => _statsController.stream;

  Future<void> fetchPayments({
    int page = 1,
    int limit = 2000000000000000000,
    String? status,
    String? type,
    String? searchQuery,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null && status != 'all') 'status': status,
        if (type != null && type != 'all') 'type': type,
        // We handle search locally to ensure it works for all fields (seller, phone, etc.)
        // if (searchQuery != null) 'search': searchQuery,
        if (dateFrom != null) 'dateFrom': dateFrom,
        if (dateTo != null) 'dateTo': dateTo,
      };

      final uri = Uri.parse(
        '${NetworkServices.endpoint}/payments',
      ).replace(queryParameters: queryParams);

      final response = await _api.getRequest(uri.toString());
      final data = jsonDecode(response.body);
      debugPrint("Payments API Response: ${jsonEncode(data)}");

      if (data['success'] == true) {
        final paymentResponse = PaymentResponse.fromJson(data);

        var payments = paymentResponse.data;
        final stats = paymentResponse.summary;

        // Local Filtering
        if (searchQuery != null && searchQuery.isNotEmpty) {
          final query = searchQuery.toLowerCase();
          payments =
              payments.where((p) {
                final name = p.personName.toLowerCase();
                final phone = p.personPhone.toLowerCase();
                final orderId = p.orderId.toLowerCase();
                final notes = p.notes.toLowerCase();

                return name.contains(query) ||
                    phone.contains(query) ||
                    orderId.contains(query) ||
                    notes.contains(query);
              }).toList();
        }

        debugPrint(
          "Parsed ${payments.length} payments and stats: ${stats.totalPending}",
        );
        _paymentsController.add(payments);
        _statsController.add(stats);
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch payments');
      }
    } catch (e) {
      debugPrint("Error fetching payments: $e");
      rethrow;
    }
  }

  Future<void> clearPayment(
    String id, {
    String? referenceId,
    String? notes,
  }) async {
    try {
      final response = await _api.postRequest(
        '${NetworkServices.endpoint}/payments/$id/clear',
        body: {
          if (referenceId != null) 'referenceId': referenceId,
          if (notes != null) 'notes': notes,
        },
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        // Refresh payments after clearing
        await fetchPayments();
      } else {
        throw Exception(data['message'] ?? 'Failed to clear payment');
      }
    } catch (e) {
      debugPrint("Error clearing payment: $e");
      rethrow;
    }
  }

  Future<void> syncPayments() async {
    try {
      final response = await _api.postRequest(
        '${NetworkServices.endpoint}/payments/sync',
        body: {},
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        await fetchPayments();
      } else {
        throw Exception(data['message'] ?? 'Sync failed');
      }
    } catch (e) {
      debugPrint("Error syncing payments: $e");
      rethrow;
    }
  }

  Future<void> rebuildSheet() async {
    try {
      final response = await _api.postRequest(
        '${NetworkServices.endpoint}/payments/rebuild-sheet',
        body: {},
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        await fetchPayments();
      } else {
        throw Exception(data['message'] ?? 'Rebuild failed');
      }
    } catch (e) {
      debugPrint("Error rebuilding sheet: $e");
      rethrow;
    }
  }

  Future<void> exportPayments() async {
    try {
      final url = '${NetworkServices.endpoint}/payments/export';
      debugPrint("Exporting payments from: $url");

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
          webOnlyWindowName: '_self',
        );
      } else {
        throw Exception('Could not launch export URL');
      }
    } catch (e) {
      debugPrint("Error exporting payments: $e");
      rethrow;
    }
  }

  Future<void> importPayments() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'csv', 'xls'],
        withData: true, // Required for Web to get bytes
      );

      if (result != null && result.files.single.bytes != null) {
        final response = await _api.uploadFile(
          '${NetworkServices.endpoint}/payments/import',
          bytes: result.files.single.bytes,
          filename: result.files.single.name,
          fileField: 'file',
        );

        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);

        if (data['success'] == true) {
          await fetchPayments();
        } else {
          throw Exception(data['message'] ?? 'Import failed');
        }
      }
    } catch (e) {
      debugPrint("Error importing payments: $e");
      rethrow;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchPayments();
  }

  @override
  void onClose() {
    _paymentsController.close();
    _statsController.close();
    super.onClose();
  }
}
