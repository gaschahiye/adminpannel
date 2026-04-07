import 'package:flutter/material.dart';

class PaymentItem {
  final String orderId;
  final String personName;
  final String personType; // 'seller' or 'buyer'
  final String phone;
  final String paymentType; // 'seller_payment', 'refund'
  final double amount;
  final String paymentMethod;
  final String status; // 'pending', 'completed', 'failed'
  final DateTime date;
  final String? sellerId;
  final String? buyerId;
  final String? originalPaymentMethod;
  final bool isSellerLiability;
  final String? sellerName;
  final String? sellerPhone;

  PaymentItem({
    required this.orderId,
    required this.personName,
    required this.personType,
    required this.phone,
    required this.paymentType,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.date,
    this.sellerId,
    this.buyerId,
    this.originalPaymentMethod,
    this.isSellerLiability = false,
    this.sellerName,
    this.sellerPhone,
  });
}

class DashboardSummary {
  final double totalPending;
  final double amountToSellers;
  final double amountToRefund;
  final double clearedAmount;
  final int pendingTransactions;
  final int clearedTransactions;

  DashboardSummary({
    required this.totalPending,
    required this.amountToSellers,
    required this.amountToRefund,
    required this.clearedAmount,
    required this.pendingTransactions,
    required this.clearedTransactions,
  });
}