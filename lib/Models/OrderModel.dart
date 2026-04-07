// models/order_models.dart
import 'dart:convert';

/// =======================
/// ORDERS RESPONSE
/// =======================
class OrdersResponse {
  final bool success;
  final OrdersData data;

  OrdersResponse({required this.success, required this.data});

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    return OrdersResponse(
      success: json['success'] ?? false,
      data: OrdersData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {'success': success, 'data': data.toJson()};
}

/// =======================
/// ORDERS DATA
/// =======================
class OrdersData {
  final List<Order> orders;
  final Summary summary;
  final List<StatusDistribution> statusDistribution;
  final List<PaymentMethodDistribution> paymentMethodDistribution;
  final Pagination pagination;

  OrdersData({
    required this.orders,
    required this.summary,
    required this.statusDistribution,
    required this.paymentMethodDistribution,
    required this.pagination,
  });

  factory OrdersData.fromJson(Map<String, dynamic> json) {
    return OrdersData(
      orders:
          (json['orders'] as List? ?? [])
              .map((e) => Order.fromJson(e))
              .toList(),
      summary: Summary.fromJson(json['summary'] ?? {}),
      statusDistribution:
          (json['statusDistribution'] as List? ?? [])
              .map((e) => StatusDistribution.fromJson(e))
              .toList(),
      paymentMethodDistribution:
          (json['paymentMethodDistribution'] as List? ?? [])
              .map((e) => PaymentMethodDistribution.fromJson(e))
              .toList(),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'orders': orders.map((e) => e.toJson()).toList(),
    'summary': summary.toJson(),
    'statusDistribution': statusDistribution.map((e) => e.toJson()).toList(),
    'paymentMethodDistribution':
        paymentMethodDistribution.map((e) => e.toJson()).toList(),
    'pagination': pagination.toJson(),
  };
}

/// =======================
/// ORDER MODEL
/// =======================
class Order {
  final String id;
  final String orderId;
  final User buyer;
  final Seller seller;
  final String orderType;
  final String cylinderSize;
  final int quantity;
  final Pricing pricing;
  final String status;
  final List<StatusHistory> statusHistory;
  final Payment payment;
  final bool isUrgent;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String qrCode;
  final String deliveryAddress;
  final bool paymentOverdue;
  final int daysOverdue;
  final List<PaymentTimeline> paymentTimeline;
  final String? warehouseId;
  final String? driverId;
  final List<CylinderVerification>? cylinderVerification;
  final List<Addon> addOns;
  final double? deliveryLat;
  final double? deliveryLng;

  Order({
    required this.id,
    required this.orderId,
    required this.buyer,
    required this.seller,
    required this.orderType,
    required this.cylinderSize,
    required this.quantity,
    required this.pricing,
    required this.status,
    required this.statusHistory,
    required this.payment,
    required this.isUrgent,
    required this.createdAt,
    required this.updatedAt,
    required this.qrCode,
    required this.deliveryAddress,
    required this.paymentOverdue,
    required this.daysOverdue,
    required this.paymentTimeline,
    this.warehouseId,
    this.driverId,
    this.cylinderVerification,
    required this.addOns,
    this.deliveryLat,
    this.deliveryLng,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    double? lat;
    double? lng;

    if (json['deliveryLocation'] != null &&
        json['deliveryLocation'] is Map &&
        json['deliveryLocation']['location'] != null &&
        json['deliveryLocation']['location']['coordinates'] != null &&
        (json['deliveryLocation']['location']['coordinates'] as List)
            .isNotEmpty) {
      final coords =
          json['deliveryLocation']['location']['coordinates'] as List;
      if (coords.length >= 2) {
        lng = (coords[0] as num).toDouble();
        lat = (coords[1] as num).toDouble();
      }
    }

    return Order(
      id: _parseId(json['_id']),
      orderId: _safeString(json['orderId']),
      buyer: User.fromJson(json['buyer'] ?? {}),
      seller: Seller.fromJson(json['seller'] ?? {}),
      orderType: _safeString(json['orderType']),
      cylinderSize: _safeString(json['cylinderSize']),
      quantity: json['quantity'] ?? 0,
      pricing: Pricing.fromJson(json['pricing'] ?? {}),
      status: _safeString(json['status']),
      statusHistory:
          (json['statusHistory'] as List? ?? [])
              .map((e) => StatusHistory.fromJson(e))
              .toList(),
      payment: Payment.fromJson(json['payment'] ?? {}),
      isUrgent: json['isUrgent'] ?? false,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      qrCode: _parseQrCode(json['qrCode']),
      deliveryAddress: _parseDeliveryAddress(json),
      paymentOverdue: json['paymentOverdue'] ?? false,
      daysOverdue: json['daysOverdue'] ?? 0,
      paymentTimeline:
          (json['paymentTimeline'] as List? ?? [])
              .map((e) => PaymentTimeline.fromJson(e))
              .toList(),
      warehouseId: _parseId(json['warehouse']),
      driverId: _parseId(json['driver']),
      cylinderVerification:
          (json['cylinderVerification'] as List? ?? [])
              .map((e) => CylinderVerification.fromJson(e))
              .toList(),
      addOns:
          (json['addOns'] as List? ?? [])
              .map((e) => Addon.fromJson(e))
              .toList(),
      deliveryLat: lat,
      deliveryLng: lng,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'orderId': orderId,
    'buyer': buyer.toJson(),
    'seller': seller.toJson(),
    'orderType': orderType,
    'cylinderSize': cylinderSize,
    'quantity': quantity,
    'pricing': pricing.toJson(),
    'status': status,
    'statusHistory': statusHistory.map((e) => e.toJson()).toList(),
    'payment': payment.toJson(),
    'isUrgent': isUrgent,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'qrCode': qrCode,
    'deliveryAddress': deliveryAddress,
    'paymentOverdue': paymentOverdue,
    'daysOverdue': daysOverdue,
    'paymentTimeline': paymentTimeline.map((e) => e.toJson()).toList(),
    'warehouse': warehouseId,
    'driver': driverId,
    'cylinderVerification':
        cylinderVerification?.map((e) => e.toJson()).toList(),
    'addOns': addOns.map((e) => e.toJson()).toList(),
    'deliveryLat': deliveryLat,
    'deliveryLng': deliveryLng,
  };

  /// ===== Payment Summary =====
  PaymentSummary getPaymentSummary() {
    double totalPaid = 0;
    double totalRefunded = 0;
    double pendingAmount = 0;

    for (var t in paymentTimeline) {
      if (t.type == 'payment' && t.status == 'completed') {
        totalPaid += t.amount;
      } else if (t.type == 'refund' && t.status == 'completed') {
        totalRefunded += t.amount;
      } else if (t.status == 'pending') {
        pendingAmount += t.amount;
      }
    }

    return PaymentSummary(
      totalPaid: totalPaid,
      totalRefunded: totalRefunded,
      pendingAmount: pendingAmount,
      totalAmount: pricing.grandTotal.toDouble(),
    );
  }
}

/// =======================
/// ADDON
/// =======================
class Addon {
  final String id;
  final String? name;
  final double price;
  final int quantity;

  Addon({
    required this.id,
    this.name,
    required this.price,
    required this.quantity,
  });

  factory Addon.fromJson(Map<String, dynamic> json) {
    return Addon(
      id: _parseId(json['_id']),
      name: _safeStringNullable(json['title']),
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'price': price,
    'quantity': quantity,
  };
}

/// =======================
/// USER
/// =======================
class User {
  final String id;
  final String phoneNumber;
  final String fullName;

  User({required this.id, required this.phoneNumber, required this.fullName});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _parseId(json['_id']),
      phoneNumber: _safeString(json['phoneNumber']),
      fullName: _safeString(json['fullName']),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'phoneNumber': phoneNumber,
    'fullName': fullName,
  };
}

/// =======================
/// SELLER
/// =======================
class Seller {
  final String id;
  final String phoneNumber;
  final String businessName;
  final String? bankAccount;
  final String? bankName;
  final String? easypaisaAccount;

  Seller({
    required this.id,
    required this.phoneNumber,
    required this.businessName,
    this.bankAccount,
    this.bankName,
    this.easypaisaAccount,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: _parseId(json['_id']),
      phoneNumber: _safeString(json['phoneNumber']),
      businessName: _safeString(json['businessName']),
      bankAccount: _safeStringNullable(json['bankAccount']),
      bankName: _safeStringNullable(json['bankName']),
      easypaisaAccount: _safeStringNullable(json['easypaisaAccount']),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'phoneNumber': phoneNumber,
    'businessName': businessName,
    'bankAccount': bankAccount,
    'bankName': bankName,
    'easypaisaAccount': easypaisaAccount,
  };
}

/// =======================
/// PRICING
/// =======================
class Pricing {
  final int cylinderPrice;
  final int deliveryCharges;
  final int grandTotal;
  final int? securityCharges;
  final int? urgentDeliveryFee;
  final int? addOnsTotal;
  final int? subtotal;

  Pricing({
    required this.cylinderPrice,
    required this.deliveryCharges,
    required this.grandTotal,
    this.securityCharges,
    this.urgentDeliveryFee,
    this.addOnsTotal,
    this.subtotal,
  });

  factory Pricing.fromJson(Map<String, dynamic> json) {
    return Pricing(
      cylinderPrice: json['cylinderPrice'] ?? 0,
      deliveryCharges: json['deliveryCharges'] ?? 0,
      grandTotal: json['grandTotal'] ?? 0,
      securityCharges: json['securityCharges'],
      urgentDeliveryFee: json['urgentDeliveryFee'],
      addOnsTotal: json['addOnsTotal'],
      subtotal: json['subtotal'],
    );
  }

  Map<String, dynamic> toJson() => {
    'cylinderPrice': cylinderPrice,
    'deliveryCharges': deliveryCharges,
    'grandTotal': grandTotal,
    'securityCharges': securityCharges,
    'urgentDeliveryFee': urgentDeliveryFee,
    'addOnsTotal': addOnsTotal,
    'subtotal': subtotal,
  };
}

/// =======================
/// STATUS HISTORY
/// =======================
class StatusHistory {
  final String status;
  final String updatedBy;
  final DateTime timestamp;
  final String? notes;
  final String? id;

  StatusHistory({
    required this.status,
    required this.updatedBy,
    required this.timestamp,
    this.notes,
    this.id,
  });

  factory StatusHistory.fromJson(Map<String, dynamic> json) {
    return StatusHistory(
      status: _safeString(json['status']),
      updatedBy: _parseId(json['updatedBy']),
      timestamp: _parseDate(json['timestamp']),
      notes: _safeStringNullable(json['notes']),
      id: _parseId(json['_id']),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'updatedBy': updatedBy,
    'timestamp': timestamp.toIso8601String(),
    'notes': notes,
    '_id': id,
  };
}

/// =======================
/// PAYMENT
/// =======================
class Payment {
  final String method;
  final String status;
  final String? referenceId;
  final DateTime? paidAt;

  Payment({
    required this.method,
    required this.status,
    this.referenceId,
    this.paidAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      method: _safeString(json['method']),
      status: _safeString(json['status']),
      referenceId: _safeStringNullable(json['referenceId']),
      paidAt: json['paidAt'] != null ? _parseDate(json['paidAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'method': method,
    'status': status,
    'referenceId': referenceId,
    'paidAt': paidAt?.toIso8601String(),
  };
}

/// =======================
/// PAYMENT TIMELINE
/// =======================
class PaymentTimeline {
  final String type;
  final double amount;
  final String status;
  final DateTime createdAt;
  final String? processedBy;
  final String? referenceId;
  final String? notes;
  final String? id;
  final String? liableParty;

  PaymentTimeline({
    required this.type,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.processedBy,
    this.referenceId,
    this.notes,
    this.id,
    this.liableParty,
  });

  factory PaymentTimeline.fromJson(Map<String, dynamic> json) {
    return PaymentTimeline(
      type: _safeString(json['type']),
      amount: (json['amount'] ?? 0).toDouble(),
      status: _safeString(json['status']),
      createdAt: _parseDate(json['createdAt']),
      processedBy: _parseId(json['processedBy']),
      referenceId: _safeStringNullable(json['referenceId']),
      notes: _safeStringNullable(json['notes']),
      id: _parseId(json['_id']),
      liableParty: _parseId(json['liableParty']),
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'amount': amount,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'processedBy': processedBy,
    'referenceId': referenceId,
    'notes': notes,
    '_id': id,
    'liableParty': liableParty,
  };
}

/// =======================
/// CYLINDER VERIFICATION
/// =======================
class CylinderVerification {
  final String? photo;
  final double tareWeight;
  final double netWeight;
  final double grossWeight;
  final String serialNumber;
  final double weightDifference;
  final DateTime verifiedAt;
  final String id;

  CylinderVerification({
    this.photo,
    required this.tareWeight,
    required this.netWeight,
    required this.grossWeight,
    required this.serialNumber,
    required this.weightDifference,
    required this.verifiedAt,
    required this.id,
  });

  factory CylinderVerification.fromJson(Map<String, dynamic> json) {
    return CylinderVerification(
      photo: _safeStringNullable(json['photo']),
      tareWeight: (json['tareWeight'] ?? 0).toDouble(),
      netWeight: (json['netWeight'] ?? 0).toDouble(),
      grossWeight: (json['grossWeight'] ?? 0).toDouble(),
      serialNumber: _safeString(json['serialNumber']),
      weightDifference: (json['weightDifference'] ?? 0).toDouble(),
      verifiedAt: _parseDate(json['verifiedAt']),
      id: _parseId(json['_id']),
    );
  }

  Map<String, dynamic> toJson() => {
    'photo': photo,
    'tareWeight': tareWeight,
    'netWeight': netWeight,
    'grossWeight': grossWeight,
    'serialNumber': serialNumber,
    'weightDifference': weightDifference,
    'verifiedAt': verifiedAt.toIso8601String(),
    '_id': id,
  };
}

/// =======================
/// PAYMENT SUMMARY
/// =======================
class PaymentSummary {
  final double totalPaid;
  final double totalRefunded;
  final double pendingAmount;
  final double totalAmount;

  PaymentSummary({
    required this.totalPaid,
    required this.totalRefunded,
    required this.pendingAmount,
    required this.totalAmount,
  });
}

/// =======================
/// SUMMARY / STATS
/// =======================
class Summary {
  final int totalOrders;
  final double totalRevenue;

  Summary({required this.totalOrders, required this.totalRevenue});

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalOrders: json['totalOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'totalOrders': totalOrders,
    'totalRevenue': totalRevenue,
  };
}

class StatusDistribution {
  final int count;
  final String status;

  StatusDistribution({required this.count, required this.status});

  factory StatusDistribution.fromJson(Map<String, dynamic> json) {
    return StatusDistribution(
      count: json['count'] ?? 0,
      status: _safeString(json['status']),
    );
  }

  Map<String, dynamic> toJson() => {'count': count, 'status': status};
}

class PaymentMethodDistribution {
  final int count;
  final String method;

  PaymentMethodDistribution({required this.count, required this.method});

  factory PaymentMethodDistribution.fromJson(Map<String, dynamic> json) {
    return PaymentMethodDistribution(
      count: json['count'] ?? 0,
      method: _safeString(json['method']),
    );
  }

  Map<String, dynamic> toJson() => {'count': count, 'method': method};
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      hasNext: json['hasNext'] ?? false,
      hasPrev: json['hasPrev'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'currentPage': currentPage,
    'totalPages': totalPages,
    'hasNext': hasNext,
    'hasPrev': hasPrev,
  };
}

/// =======================
/// HELPERS (CRITICAL)
/// =======================
String _parseId(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is Map) {
    // If it's a map (populated object), extract the ID
    return value['_id'] ??
        value['\$oid'] ??
        value['id'] ??
        value.values.first.toString();
  }
  return value.toString();
}

String _parseQrCode(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is Map) {
    return value['qrCodeUrl'] ?? value['code'] ?? _parseId(value);
  }
  return value.toString();
}

String _parseDeliveryAddress(Map<String, dynamic> json) {
  if (json['deliveryAddress'] != null &&
      json['deliveryAddress'] is String &&
      json['deliveryAddress'].toString().isNotEmpty) {
    return json['deliveryAddress'];
  }

  if (json['deliveryLocation'] != null && json['deliveryLocation'] is Map) {
    final loc = json['deliveryLocation'];
    if (loc['address'] != null) return loc['address'].toString();
  }

  return 'No Address';
}

DateTime _parseDate(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is String) return DateTime.parse(value);
  if (value is Map) return DateTime.parse(value['\$date']);
  return DateTime.now();
}

String _safeString(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is Map)
    return _parseId(
      value,
    ); // Assuming map implies an object reference with an ID
  return value.toString();
}

String? _safeStringNullable(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is Map) return _parseId(value);
  return value.toString();
}
