import 'package:flutter/material.dart';

enum PaymentType {
  sellerPayment('seller_payment'),
  refund('refund'),
  partialRefund('partial_refund');

  final String value;
  const PaymentType(this.value);

  factory PaymentType.fromString(String value) {
    switch (value) {
      case 'seller_payment':
        return PaymentType.sellerPayment;
      case 'refund':
        return PaymentType.refund;
      case 'partial_refund':
        return PaymentType.partialRefund;
      default:
        return PaymentType.sellerPayment;
    }
  }
}

enum PaymentStatus {
  pending('pending'),
  completed('completed'),
  failed('failed');

  final String value;
  const PaymentStatus(this.value);

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
  seller('seller'),
  platform('platform');

  final String value;
  const LiabilityType(this.value);

  Color get color {
    switch (this) {
      case LiabilityType.seller:
        return const Color(0xFFF59E0B);
      case LiabilityType.platform:
        return const Color(0xFF3B82F6);
    }
  }
}

class PaymentItem {
  final String id;
  final String orderId;
  final String personName;
  final String personType; // 'seller' or 'buyer'
  final String phone;
  final PaymentType paymentType;
  final double amount;
  final String paymentMethod;
  final PaymentStatus status;
  final DateTime date;
  final String? notes;
  final String? sellerId;
  final String? buyerId;
  final String? originalPaymentMethod;
  final LiabilityType? liabilityType;
  final String? referenceId;
  final DateTime? processedAt;
  final String? processedBy;

  PaymentItem({
    required this.id,
    required this.orderId,
    required this.personName,
    required this.personType,
    required this.phone,
    required this.paymentType,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.date,
    this.notes,
    this.sellerId,
    this.buyerId,
    this.originalPaymentMethod,
    this.liabilityType,
    this.referenceId,
    this.processedAt,
    this.processedBy,
  });

  factory PaymentItem.fromJson(Map<String, dynamic> json) {
    return PaymentItem(
      id: json['id'] ?? '',
      orderId: json['orderId'] ?? '',
      personName: json['personName'] ?? '',
      personType: json['personType'] ?? '',
      phone: json['phone'] ?? '',
      paymentType: PaymentType.fromString(json['paymentType'] ?? ''),
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      status: PaymentStatus.values.firstWhere(
            (e) => e.value == (json['status'] ?? 'pending'),
        orElse: () => PaymentStatus.pending,
      ),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      notes: json['notes'],
      sellerId: json['sellerId'],
      buyerId: json['buyerId'],
      originalPaymentMethod: json['originalPaymentMethod'],
      liabilityType: json['liabilityType'] != null
          ? (json['liabilityType'] == 'seller'
          ? LiabilityType.seller
          : LiabilityType.platform)
          : null,
      referenceId: json['referenceId'],
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'])
          : null,
      processedBy: json['processedBy'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderId': orderId,
    'personName': personName,
    'personType': personType,
    'phone': phone,
    'paymentType': paymentType.value,
    'amount': amount,
    'paymentMethod': paymentMethod,
    'status': status.value,
    'date': date.toIso8601String(),
    'notes': notes,
    'sellerId': sellerId,
    'buyerId': buyerId,
    'originalPaymentMethod': originalPaymentMethod,
    'liabilityType': liabilityType?.value,
    'referenceId': referenceId,
    'processedAt': processedAt?.toIso8601String(),
    'processedBy': processedBy,
  };
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
  final Map<String, int> statusDistribution;

  PaymentSummary({
    required this.totalPending,
    required this.amountToSellers,
    required this.amountToRefund,
    required this.clearedAmount,
    required this.pendingCount,
    required this.clearedCount,
    required this.pendingSellerPayments,
    required this.pendingRefunds,
    required this.statusDistribution,
  });
}

class PaymentTimelineItem {
  final String id;
  final PaymentType type;
  final double amount;
  final PaymentStatus status;
  final DateTime createdAt;
  final String? referenceId;
  final String? notes;
  final LiabilityType? liabilityType;
  final String? processedBy;
  final DateTime? processedAt;

  PaymentTimelineItem({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.referenceId,
    this.notes,
    this.liabilityType,
    this.processedBy,
    this.processedAt,
  });

  String get displayTitle {
    switch (type) {
      case PaymentType.sellerPayment:
        return status == PaymentStatus.completed
            ? 'Payment to Seller'
            : 'Pending Seller Payment';
      case PaymentType.refund:
        return liabilityType == LiabilityType.seller
            ? 'Seller Liability Refund'
            : 'Customer Refund';
      case PaymentType.partialRefund:
        return 'Partial Refund';
    }
  }

  IconData get icon {
    switch (type) {
      case PaymentType.sellerPayment:
        return Icons.account_balance_wallet;
      case PaymentType.refund:
      case PaymentType.partialRefund:
        return Icons.refresh;
    }
  }

  Color get color {
    switch (type) {
      case PaymentType.sellerPayment:
        return const Color(0xFF3B82F6);
      case PaymentType.refund:
        return liabilityType == LiabilityType.seller
            ? const Color(0xFFF59E0B)
            : const Color(0xFF8B5CF6);
      case PaymentType.partialRefund:
        return const Color(0xFF10B981);
    }
  }
}

class PaymentFilter {
  PaymentStatus? status;
  PaymentType? type;
  DateTime? startDate;
  DateTime? endDate;
  String? searchQuery;

  PaymentFilter({
    this.status,
    this.type,
    this.startDate,
    this.endDate,
    this.searchQuery,
  });

  bool get hasFilters =>
      status != null ||
          type != null ||
          startDate != null ||
          endDate != null ||
          (searchQuery != null && searchQuery!.isNotEmpty);
}