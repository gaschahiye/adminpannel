import 'package:flutter/material.dart';

enum PaymentType {
  pickupFee('pickup_fee'),
  deliveryFee('delivery_fee'),
  refund('refund'),
  sale('sale'),
  other('other'),
  sellerPayment('seller_payment'),
  partialRefund('partial_refund');

  final String value;
  const PaymentType(this.value);

  factory PaymentType.fromString(String value) {
    return PaymentType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentType.other,
    );
  }

  String get displayTitle {
    switch (this) {
      case PaymentType.pickupFee:
        return 'Pickup Fee';
      case PaymentType.deliveryFee:
        return 'Delivery Fee';
      case PaymentType.refund:
        return 'Refund';
      case PaymentType.sale:
        return 'Sale';
      case PaymentType.sellerPayment:
        return 'Seller Payment';
      case PaymentType.partialRefund:
        return 'Partial Refund';
      default:
        return 'Other';
    }
  }
}

enum PaymentStatus {
  pending('pending'),
  completed('completed'),
  failed('failed');

  final String value;
  const PaymentStatus(this.value);

  factory PaymentStatus.fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentStatus.pending,
    );
  }

  Color get color {
    switch (this) {
      case PaymentStatus.pending:
        return const Color(0xFFF59E0B);
      case PaymentStatus.completed:
        return const Color(0xFF10B981);
      case PaymentStatus.failed:
        return const Color(0xFFEF4444);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case PaymentStatus.pending:
        return const Color(0x14F59E0B);
      case PaymentStatus.completed:
        return const Color(0x1410B981);
      case PaymentStatus.failed:
        return const Color(0x14EF4444);
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentStatus.pending:
        return Icons.pending;
      case PaymentStatus.completed:
        return Icons.check_circle;
      case PaymentStatus.failed:
        return Icons.error;
    }
  }
}

enum LiabilityType {
  revenue('revenue'),
  liability('liability'),
  refundable('refundable'),
  seller('seller'),
  platform('platform');

  final String value;
  const LiabilityType(this.value);

  factory LiabilityType.fromString(String value) {
    return LiabilityType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => LiabilityType.revenue,
    );
  }

  Color get color {
    switch (this) {
      case LiabilityType.revenue:
        return const Color(0xFF10B981);
      case LiabilityType.liability:
        return const Color(0xFFF59E0B);
      case LiabilityType.refundable:
        return const Color(0xFF3B82F6);
      case LiabilityType.seller:
        return const Color(0xFFF59E0B);
      case LiabilityType.platform:
        return const Color(0xFF3B82F6);
    }
  }
}

class PaymentTimelineEntry {
  final String id;
  final String timelineId;
  final String orderId;
  final DateTime date;
  final String personName;
  final String personType;
  final String personPhone;
  final PaymentType type;
  final LiabilityType liability;
  final double amount;
  final String paymentMethod;
  final PaymentStatus status;
  final String notes;
  final String? sellerId;
  final String? buyerId;
  final String? driverId;
  final String? originalPaymentMethod;
  final String? cause;

  PaymentTimelineEntry({
    required this.id,
    required this.timelineId,
    required this.orderId,
    required this.date,
    required this.personName,
    required this.personType,
    required this.personPhone,
    required this.type,
    required this.liability,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.notes,
    this.sellerId,
    this.buyerId,
    this.driverId,
    this.originalPaymentMethod,
    this.cause,
  });

  String get displayStatus {
    if ((type == PaymentType.deliveryFee || type == PaymentType.pickupFee) &&
        status == PaymentStatus.completed) {
      return 'RECEIVED';
    }
    return status.value.toUpperCase();
  }

  factory PaymentTimelineEntry.fromJson(dynamic json) {
    if (json is! Map) {
      return PaymentTimelineEntry(
        id: '',
        timelineId: '',
        orderId: '',
        date: DateTime.now(),
        personName: '',
        personType: '',
        personPhone: '',
        type: PaymentType.other,
        liability: LiabilityType.revenue,
        amount: 0,
        paymentMethod: '',
        status: PaymentStatus.pending,
        notes: '',
      );
    }
    return PaymentTimelineEntry(
      id: (json['id'] ?? '').toString(),
      timelineId: (json['timelineId'] ?? '').toString(),
      orderId: (json['orderId'] ?? '').toString(),
      date:
          json['date'] != null
              ? DateTime.parse(json['date'].toString())
              : DateTime.now(),
      personName: (json['personName'] ?? '').toString(),
      personType: (json['personType'] ?? '').toString(),
      personPhone: (json['phone'] ?? json['personPhone'] ?? '').toString(),
      type: PaymentType.fromString(
        (json['paymentType'] ?? json['type'] ?? '').toString(),
      ),
      liability: LiabilityType.fromString(
        (json['liabilityType'] ?? json['liability'] ?? '').toString(),
      ),
      amount: PaymentSummary._toDouble(json['amount']),
      paymentMethod: (json['paymentMethod'] ?? '').toString(),
      status: PaymentStatus.fromString(
        (json['status'] ?? 'pending').toString(),
      ),
      notes: (json['notes'] ?? '').toString(),
      sellerId: (json['sellerId'])?.toString(),
      buyerId: (json['buyerId'])?.toString(),
      driverId: (json['driverId'])?.toString(),
      originalPaymentMethod: (json['originalPaymentMethod'])?.toString(),
      cause: (json['cause'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timelineId': timelineId,
      'orderId': orderId,
      'date': date.toIso8601String(),
      'personName': personName,
      'personType': personType,
      'phone': personPhone,
      'paymentType': type.value,
      'liabilityType': liability.value,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': status.value,
      'notes': notes,
      'sellerId': sellerId,
      'buyerId': buyerId,
      'driverId': driverId,
      'originalPaymentMethod': originalPaymentMethod,
      'cause': cause,
    };
  }
}

class PaymentSummary {
  final double totalPending;
  final double amountToSellers;
  final double amountToRefund;
  final double clearedAmount;
  final int pendingCount;
  final int clearedCount;
  final double pendingSellerPayments;

  final double pendingRefunds;
  final double refundAmount;
  final double companyRevenue;
  final double totalAmount;
  final Map<String, int> statusDistribution;

  PaymentSummary({
    this.totalPending = 0,
    this.amountToSellers = 0,
    this.amountToRefund = 0,
    this.clearedAmount = 0,
    this.pendingCount = 0,
    this.clearedCount = 0,
    this.pendingSellerPayments = 0,
    this.pendingRefunds = 0,
    this.refundAmount = 0,
    this.companyRevenue = 0,
    this.totalAmount = 0,
    this.statusDistribution = const {},
  });

  factory PaymentSummary.fromJson(dynamic json) {
    if (json is! Map) {
      return PaymentSummary();
    }

    Map<String, int> distribution = {};
    if (json['statusDistribution'] is Map) {
      (json['statusDistribution'] as Map).forEach((key, value) {
        distribution[key.toString()] = (value as num).toInt();
      });
    }

    return PaymentSummary(
      totalPending: _toDouble(json['totalPending']),
      amountToSellers: _toDouble(json['amountToSellers']),
      // Map 'amountToRefund' OR 'refundAmount' to our model's refundAmount logic if needed,
      // but user specifically asked for new fields.
      // Let's keep existing fields for backward compatibility if code uses them,
      // and add the new ones.
      amountToRefund: _toDouble(json['amountToRefund']),
      clearedAmount: _toDouble(json['clearedAmount'] ?? json['totalCleared']),
      pendingCount: (json['pendingCount'] ?? 0).toInt(),
      clearedCount: (json['clearedCount'] ?? 0).toInt(),
      pendingSellerPayments: _toDouble(json['pendingSellerPayments']),
      pendingRefunds: _toDouble(json['pendingRefunds']),
      refundAmount: _toDouble(json['refundAmount']),
      companyRevenue: _toDouble(json['companyRevenue']),
      totalAmount: _toDouble(json['totalAmount']),
      statusDistribution: distribution,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class PaymentPagination {
  final int currentPage;
  final int totalPages;
  final int totalEntries;
  final bool hasNext;

  PaymentPagination({
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalEntries = 0,
    this.hasNext = false,
  });

  factory PaymentPagination.fromJson(dynamic json) {
    if (json is! Map) return PaymentPagination();
    return PaymentPagination(
      currentPage: (json['currentPage'] ?? 1).toInt(),
      totalPages: (json['totalPages'] ?? 1).toInt(),
      totalEntries: (json['totalEntries'] ?? 0).toInt(),
      hasNext: json['hasNext'] ?? false,
    );
  }
}

class PaymentResponse {
  final bool success;
  final List<PaymentTimelineEntry> data;
  final PaymentSummary summary;
  final PaymentPagination? pagination;

  PaymentResponse({
    required this.success,
    required this.data,
    required this.summary,
    this.pagination,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      success: json['success'] ?? false,
      data:
          (json['data'] as List? ?? [])
              .map((item) => PaymentTimelineEntry.fromJson(item))
              .toList(),
      summary: PaymentSummary.fromJson(json['summary']),
      pagination:
          json['pagination'] != null
              ? PaymentPagination.fromJson(json['pagination'])
              : null,
    );
  }
}
