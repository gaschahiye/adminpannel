import 'Models/OrderModel.dart';
import 'Models/PaymentItemModel.dart';

class DummyDataService {
  static List<PaymentItem> getSamplePayments() {
    return [
      PaymentItem(
        orderId: '83318',
        personName: 'GasPoint Depot',
        personType: 'seller',
        phone: '03001234567',
        paymentType: 'seller_payment',
        amount: 7500,
        paymentMethod: 'Bank Transfer',
        status: 'pending',
        date: DateTime(2025, 12, 12),
        sellerId: 'seller_123',
      ),
      PaymentItem(
        orderId: '83318',
        personName: 'inam',
        personType: 'buyer',
        phone: '923190402314',
        paymentType: 'refund',
        amount: 7600,
        paymentMethod: 'Easypaisa',
        status: 'pending',
        date: DateTime(2025, 12, 12),
        buyerId: 'buyer_456',
        originalPaymentMethod: 'easypaisa',
        isSellerLiability: true,
        sellerName: 'GasPoint Depot',
        sellerPhone: '03001234567',
      ),
      PaymentItem(
        orderId: '94903',
        personName: 'City Gas',
        personType: 'seller',
        phone: '03009876543',
        paymentType: 'seller_payment',
        amount: 9300,
        paymentMethod: 'Bank Transfer',
        status: 'completed',
        date: DateTime(2025, 11, 5),
        sellerId: 'seller_789',
      ),
    ];
  }

  static Order getSampleOrder(String orderId) {
    return Order(
      addOns: [],
      id: 'order_123',
      orderId: orderId,
      buyer: User(
        id: 'buyer_456',
        phoneNumber: '923190402314',
        fullName: 'inam',
      ),
      seller: Seller(
        id: 'seller_123',
        phoneNumber: '03001234567',
        businessName: 'GasPoint Depot',
        bankAccount: 'HBL 1234567890',
        bankName: 'Habib Bank Limited',
      ),
      orderType: 'new',
      cylinderSize: '15kg',
      quantity: 1,
      pricing: Pricing(
        cylinderPrice: 7500,
        deliveryCharges: 100,
        grandTotal: 7600,
      ),
      status: 'return_pickup',
      statusHistory: [
        StatusHistory(
          status: 'delivered',
          updatedBy: 'driver',
          timestamp: DateTime(2025, 12, 10, 10, 43),
        ),
        StatusHistory(
          status: 'return_requested',
          updatedBy: 'buyer',
          timestamp: DateTime(2025, 12, 12, 14, 5),
        ),
      ],
      payment: Payment(method: 'easypaisa', status: 'pending'),
      isUrgent: false,
      createdAt: DateTime(2025, 11, 19, 17, 4),
      updatedAt: DateTime(2025, 12, 12, 14, 5),
      deliveryAddress: 'House #123, Street 45, Lahore',
      paymentTimeline: [
        PaymentTimeline(
          type: 'payment',
          amount: 7600,
          status: 'completed',
          createdAt: DateTime(2025, 11, 19, 17, 4),
          referenceId: 'EP-123456',
        ),
        PaymentTimeline(
          type: 'refund',
          amount: 7600,
          status: 'pending',
          createdAt: DateTime(2025, 12, 12, 14, 5),
          notes: 'Return requested by buyer',
          liableParty: 'seller',
        ),
      ],
      qrCode: '',
      paymentOverdue: true,
      daysOverdue: 12,
    );
  }

  static DashboardSummary getDashboardSummary() {
    final payments = getSamplePayments();

    double totalPending = 0;
    double amountToSellers = 0;
    double amountToRefund = 0;
    double clearedAmount = 0;
    int pendingTransactions = 0;
    int clearedTransactions = 0;

    for (var payment in payments) {
      if (payment.status == 'pending') {
        totalPending += payment.amount;
        pendingTransactions++;

        if (payment.paymentType == 'seller_payment') {
          amountToSellers += payment.amount;
        } else {
          amountToRefund += payment.amount;
        }
      } else {
        clearedAmount += payment.amount;
        clearedTransactions++;
      }
    }

    return DashboardSummary(
      totalPending: totalPending,
      amountToSellers: amountToSellers,
      amountToRefund: amountToRefund,
      clearedAmount: clearedAmount,
      pendingTransactions: pendingTransactions,
      clearedTransactions: clearedTransactions,
    );
  }
}
