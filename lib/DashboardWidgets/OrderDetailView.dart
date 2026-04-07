import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Controller/orderController.dart';
import '../Models/OrderModel.dart';
import '../widgets/animations/fade_in_slide.dart';
import '../theme/theme.dart';
import 'OrderColors.dart';

class OrderDetailsView extends StatelessWidget {
  final Order order;
  final OrdersController ordersController = Get.find();

  OrderDetailsView({required this.order, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrderColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.spacingLg),
        child: FadeInSlide(
          duration: const Duration(milliseconds: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildKeyMetricsGrid(),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 1024;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: isDesktop ? 2 : 1,
                        child: Column(
                          children: [
                            _buildMainOrderCard(),
                            const SizedBox(height: 24),
                            _buildPricingSection(),
                          ],
                        ),
                      ),
                      if (isDesktop) ...[
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              _buildCustomerCard(),
                              const SizedBox(height: 24),
                              _buildAddressCard(),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              // Mobile only stack for side cards
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth <= 1024) {
                    return Column(
                      children: [
                        const SizedBox(height: 24),
                        _buildCustomerCard(),
                        const SizedBox(height: 24),
                        _buildAddressCard(),
                      ],
                    );
                  }
                  return const SizedBox();
                },
              ),
              const SizedBox(height: 24),
              _buildStatusTimeline(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        InkWell(
          onTap: () => Get.back(),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: OrderColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: OrderColors.border),
            ),
            child: Icon(
              Iconsax.arrow_left_2,
              size: 20,
              color: OrderColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Orders',
                  style: TextStyle(
                  fontFamily: 'Inter',
                    fontSize: 14,
                    color: OrderColors.textSecondary,
                  ),
                ),
                Icon(
                  Iconsax.arrow_right_3,
                  size: 14,
                  color: OrderColors.textSecondary,
                ),
                Text(
                  'Order Details',
                  style: TextStyle(
                  fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: OrderColors.textPrimary,
                  ),
                ),
              ],
            ),
            Text(
              order.orderId,
              style: TextStyle(
                  fontFamily: 'Inter',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: OrderColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const Spacer(),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [

        ElevatedButton.icon(
          onPressed: () => _showStatusDialog(),
          icon: const Icon(Iconsax.status, size: 18),
          label: Text(
            'Update Status',
            style: TextStyle(
                  fontFamily: 'Inter',fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: OrderColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: OrderColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: OrderColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: OrderColors.textPrimary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                  fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: OrderColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetricsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount =
            constraints.maxWidth > 1200
                ? 4
                : (constraints.maxWidth > 768 ? 2 : 1);

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: constraints.maxWidth > 1200 ? 2.5 : 3,
          children: [
            _buildMetricCard(
              title: 'Total Amount',
              value: 'Rs ${order.pricing.grandTotal}',
              icon: Iconsax.wallet_money,
              color: OrderColors.accentGreen,
            ),
            _buildMetricCard(
              title: 'Order Status',
              value: order.status,
              icon: _getStatusIcon(order.status),
              color: ordersController.getStatusColor(order.status),
            ),
            _buildMetricCard(
              title: 'Payment Method',
              value: order.payment.method,
              icon: Iconsax.card,
              color: OrderColors.primary,
            ),
            _buildMetricCard(
              title: 'Order Date',
              value: _formatDate(order.createdAt),
              icon: Iconsax.calendar_1,
              color: OrderColors.accentOrange,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: OrderColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: OrderColors.border),
        boxShadow: [
          BoxShadow(
            color: OrderColors.textPrimary.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                  fontFamily: 'Inter',
                    fontSize: 13,
                    color: OrderColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                  fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: OrderColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainOrderCard() {
    return Container(
      decoration: BoxDecoration(
        color: OrderColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OrderColors.border),
        boxShadow: [
          BoxShadow(
            color: OrderColors.textPrimary.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Order Items',
              style: TextStyle(
                  fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: OrderColors.textPrimary,
              ),
            ),
          ),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: OrderColors.background),
                children: [
                  _buildTableCell('Item Description', isHeader: true),
                  _buildTableCell('Size', isHeader: true),
                  _buildTableCell('Qty', isHeader: true),
                  _buildTableCell('Total', isHeader: true),
                ],
              ),
              TableRow(
                children: [
                  _buildTableCell(
                    'Gas Refill (${order.orderType})',
                    subtitle: order.isUrgent ? 'Urgent Priority' : null,
                  ),
                  _buildTableCell(order.cylinderSize),
                  _buildTableCell(order.quantity.toString()),
                  _buildTableCell(
                    'Rs ${order.pricing.cylinderPrice * order.quantity}',
                  ),
                ],
              ),
              ...order.addOns.map(
                (addon) => TableRow(
                  children: [
                    _buildTableCell(
                      addon.name ?? 'Addon Item',
                      subtitle: '${addon.name}...',
                    ),
                    _buildTableCell('-'),
                    _buildTableCell(addon.quantity.toString()),
                    _buildTableCell(
                      'Rs ${(addon.price * addon.quantity).toInt()}',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
                  fontFamily: 'Inter',
              fontSize: isHeader ? 12 : 14,
              fontWeight: isHeader ? FontWeight.w600 : FontWeight.w500,
              color:
                  isHeader
                      ? OrderColors.textSecondary
                      : OrderColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: OrderColors.accentRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  color: OrderColors.accentRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: OrderColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OrderColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: TextStyle(
                  fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: OrderColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _buildPriceRow(
            'Subtotal',
            'Rs ${order.pricing.cylinderPrice * order.quantity}',
          ),
          if (order.pricing.addOnsTotal != null &&
              order.pricing.addOnsTotal! > 0) ...[
            const SizedBox(height: 12),
            _buildPriceRow('Addons Total', 'Rs ${order.pricing.addOnsTotal}'),
          ],
          const SizedBox(height: 12),
          _buildPriceRow('Delivery Fee', 'Rs ${order.pricing.deliveryCharges}'),
          if (order.pricing.securityCharges != null &&
              order.pricing.securityCharges! > 0) ...[
            const SizedBox(height: 12),
            _buildPriceRow(
              'Security Charges',
              'Rs ${order.pricing.securityCharges}',
            ),
          ],
          if (order.isUrgent) ...[
            const SizedBox(height: 12),
            _buildPriceRow(
              'Urgent Surcharge',
              'Rs ${order.pricing.urgentDeliveryFee ?? 200}',
              isPositive: false,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grand Total',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: OrderColors.textPrimary,
                ),
              ),
              Text(
                'Rs ${order.pricing.grandTotal}',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: OrderColors.accentGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isPositive = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
                  fontFamily: 'Inter',
            color: OrderColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
                  fontFamily: 'Inter',
            color: isPositive ? OrderColors.textPrimary : OrderColors.accentRed,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: OrderColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OrderColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Details',
            style: TextStyle(
                  fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: OrderColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _buildUserLink(
            name: order.buyer.fullName,
            phone: order.buyer.phoneNumber,
            role: 'Buyer',
            icon: Iconsax.user,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Text(
            'Seller Details',
            style: TextStyle(
                  fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: OrderColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _buildUserLink(
            name: order.seller.businessName,
            phone: order.seller.phoneNumber,
            role: 'Vendor',
            icon: Iconsax.shop,
          ),
        ],
      ),
    );
  }

  Widget _buildUserLink({
    required String name,
    required String phone,
    required String role,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: OrderColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: OrderColors.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: OrderColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                phone,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: OrderColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: OrderColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            role,
            style: TextStyle(
                  fontFamily: 'Inter',
              fontSize: 12,
              color: OrderColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: OrderColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OrderColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery Address',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: OrderColors.textPrimary,
                ),
              ),
              Icon(Iconsax.map, color: OrderColors.primary, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            order.deliveryAddress,
            style: TextStyle(
                  fontFamily: 'Inter',
              fontSize: 14,
              color: OrderColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () async {
              if (order.deliveryLat != null && order.deliveryLng != null) {
                final url =
                    'https://www.google.com/maps/search/?api=1&query=${order.deliveryLat},${order.deliveryLng}';
                if (!await launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication,
                )) {
                  Get.snackbar('Error', 'Could not launch map.');
                }
              } else {
                Get.snackbar('Error', 'Location coordinates not available.');
              }
            },
            icon: const Icon(Iconsax.location, size: 18),
            label: Text(
              'View on Map',
              style: TextStyle(
                  fontFamily: 'Inter',fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: OrderColors.primary,
              side: BorderSide(color: OrderColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: OrderColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OrderColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Progress',
            style: TextStyle(
                  fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: OrderColors.textPrimary,
            ),
          ),
          const SizedBox(height: 32),
          if (order.statusHistory.isEmpty)
            Center(
              child: Text(
                'No status history recorded yet.',
                style: TextStyle(
                  fontFamily: 'Inter',color: OrderColors.textSecondary),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.statusHistory.length,
              itemBuilder: (context, index) {
                final history = order.statusHistory[index];
                final isLast = index == order.statusHistory.length - 1;
                final color = ordersController.getStatusColor(history.status);

                return IntrinsicHeight(
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.3),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: OrderColors.border,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                history.status,
                                style: TextStyle(
                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: OrderColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Updated by ${history.updatedBy} at ${_formatDateTime(history.timestamp)}',
                                style: TextStyle(
                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: OrderColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showStatusDialog() {
    final statuses = ['Pending', 'In Transit', 'Completed', 'Cancelled'];
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Update Order Status',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Current status: ${order.status}',
                style: TextStyle(
                  fontFamily: 'Inter',color: OrderColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ...statuses.map((status) {
                final isCurrent = order.status == status;
                final color = ordersController.getStatusColor(status);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      Get.back();
                      ordersController.updateOrderStatus(order.id, status);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            isCurrent
                                ? color.withOpacity(0.1)
                                : OrderColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCurrent ? color : OrderColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getStatusIcon(status),
                            color:
                                isCurrent ? color : OrderColors.textSecondary,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            status,
                            style: TextStyle(
                  fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              color:
                                  isCurrent ? color : OrderColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          if (isCurrent)
                            Icon(Iconsax.tick_circle, color: color, size: 20),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Iconsax.clock;
      case 'in transit':
      case 'in_transit':
        return Iconsax.truck_fast;
      case 'completed':
        return Iconsax.tick_circle;
      case 'cancelled':
        return Iconsax.close_circle;
      default:
        return Iconsax.info_circle;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
