// views/orders_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_responsive_admin_panel/theme/theme.dart' show AppTheme;
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
// import 'package:percent_indicator/percent_indicator.dart';

import '../Controller/adminController.dart';
import '../Controller/orderController.dart';
import '../Models/OrderModel.dart';
import 'OrderDetailView.dart';
import 'PaymentServiceCard.dart';
import '../widgets/animations/fade_in_slide.dart';
import 'OrderColors.dart';

class OrdersView extends StatelessWidget {
  final OrdersController controller = Get.find();
  final AdminController adminController = Get.find();

  OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (adminController.isViewingOrderDetails.value) {
        final order = controller.getOrderById(
          adminController.selectedOrderId.value,
        );
        if (order != null) {
          return OrderDetailsView(order: order);
        } else {
          return Center(child: Text('Order not found'));
        }
      }

      return Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Stats
                _buildHeader(),

                SizedBox(height: 24),

                // Summary Cards
                Obx(() => _buildSummaryCards()),

                SizedBox(height: 24),

                // Search and Filters
                _buildSearchFilter(),

                SizedBox(height: 24),

                // Orders Table
                _buildOrdersTable(),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Management',
                  style: TextStyle(
                    fontSize: 14,
                    color: OrderColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Orders Overview',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: OrderColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                controller.fetchOrders();
              },
              icon: Icon(Iconsax.refresh, size: 20),
              label: Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: OrderColors.surface,
                foregroundColor: OrderColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: OrderColors.border),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          'Manage and track all gas cylinder delivery orders',
          style: TextStyle(fontSize: 14, color: OrderColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    final data = controller.ordersResponse.value?.data;
    if (data == null) return const SizedBox();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 768;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isDesktop ? 4 : 2,
          crossAxisSpacing: AppTheme.spacingLg,
          mainAxisSpacing: AppTheme.spacingLg,
          childAspectRatio: isDesktop ? 1.5 : 2.0, // Adjusted aspect ratio
          children: [
            PaymentSummaryCard(
              title: 'Total Orders',
              amount: data.summary.totalOrders.toDouble(),
              subtitle: 'All time orders',
              icon: Iconsax.shopping_cart,
              color: OrderColors.primary,
              isCurrency: false,
            ),
            // PaymentSummaryCard(
            //   title: 'Total Revenue',
            //   amount: data.summary.totalRevenue,
            //   subtitle: 'Gross revenue',
            //   icon: Iconsax.money,
            //   color: OrderColors.accentGreen,
            //   isCurrency: true,
            // ),
            PaymentSummaryCard(
              title: 'Pending Orders',
              amount:
                  data.statusDistribution
                      .firstWhere(
                        (dist) => dist.status == 'Pending',
                        orElse:
                            () =>
                                StatusDistribution(count: 0, status: 'Pending'),
                      )
                      .count
                      .toDouble(),
              subtitle: 'Awaiting action',
              icon: Iconsax.clock,
              color: OrderColors.accentOrange,
              isCurrency: false,
            ),
            PaymentSummaryCard(
              title: 'In Transit',
              amount:
                  data.statusDistribution
                      .firstWhere(
                        (dist) => dist.status == 'In Transit',
                        orElse:
                            () => StatusDistribution(
                              count: 0,
                              status: 'In Transit',
                            ),
                      )
                      .count
                      .toDouble(),
              subtitle: 'Active deliveries', // Changed subtitle for clarity
              icon: Iconsax.truck_fast, // Changed icon to truck
              color: Color(0xFF3B82F6), // Blue 500
              isCurrency: false,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchFilter() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: OrderColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OrderColors.border),
        boxShadow: [
          BoxShadow(
            color: OrderColors.textPrimary.withOpacity(0.02),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: OrderColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 768;
              return Flex(
                direction: isDesktop ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment:
                    isDesktop
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.stretch,
                children: [
                  if (isDesktop)
                    Expanded(child: _buildSearchField())
                  else
                    _buildSearchField(),
                  SizedBox(width: 16, height: isDesktop ? 0 : 16),
                  if (isDesktop) ...[
                    Container(
                      height: 40,
                      width: 200,
                      child: Obx(
                        () => _buildDropdown(
                          value: controller.selectedStatus.value,
                          items: controller.statusOptions,
                          onChanged:
                              (value) =>
                                  controller.selectedStatus.value = value!,
                          hint: 'Status',
                          icon: Iconsax.status,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Container(
                      height: 40,
                      width: 200,
                      child: Obx(
                        () => _buildDropdown(
                          value: controller.selectedType.value,
                          items: controller.typeOptions,
                          onChanged:
                              (value) => controller.selectedType.value = value!,
                          hint: 'Type',
                          icon: Iconsax.category,
                        ),
                      ),
                    ),
                  ] else ...[
                    Obx(
                      () => _buildDropdown(
                        value: controller.selectedStatus.value,
                        items: controller.statusOptions,
                        onChanged:
                            (value) => controller.selectedStatus.value = value!,
                        hint: 'Status',
                        icon: Iconsax.status,
                      ),
                    ),
                    SizedBox(height: 16),
                    Obx(
                      () => _buildDropdown(
                        value: controller.selectedType.value,
                        items: controller.typeOptions,
                        onChanged:
                            (value) => controller.selectedType.value = value!,
                        hint: 'Type',
                        icon: Iconsax.category,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: (value) => controller.searchQuery.value = value,
      decoration: InputDecoration(
        hintText: 'Search orders...',
        hintStyle: TextStyle(color: OrderColors.textSecondary),
        prefixIcon: Icon(
          Iconsax.search_normal,
          color: OrderColors.textSecondary,
          size: 20,
        ),
        filled: true,
        fillColor: OrderColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: OrderColors.primary, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: OrderColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: OrderColors.textSecondary, size: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        ),
        dropdownColor: OrderColors.surface,
        icon: Icon(
          Iconsax.arrow_down_1,
          size: 16,
          color: OrderColors.textSecondary,
        ),
        style: TextStyle(color: OrderColors.textPrimary, fontSize: 14),
        items:
            items.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildOrdersTable() {
    return FadeInSlide(
      duration: Duration(milliseconds: 600),
      child: Container(
        decoration: BoxDecoration(
          color: OrderColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: OrderColors.border),
          boxShadow: [
            BoxShadow(
              color: OrderColors.textPrimary.withOpacity(0.02),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Container(
              height: 400,
              child: Center(
                child: CircularProgressIndicator(color: OrderColors.primary),
              ),
            );
          }

          if (controller.errorMessage.isNotEmpty) {
            return Container(
              height: 400,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.warning_2,
                      color: OrderColors.accentRed,
                      size: 64,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Failed to load orders',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: OrderColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: OrderColors.textSecondary),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: controller.fetchOrders,
                      child: Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OrderColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final orders = controller.filteredOrders;

          if (orders.isEmpty) {
            return Container(
              height: 400,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: OrderColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.box,
                        size: 48,
                        color: OrderColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No orders found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: OrderColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Try adjusting your search or filters',
                      style: TextStyle(color: OrderColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Orders',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: OrderColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: OrderColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${orders.length} orders found',
                        style: TextStyle(
                          color: OrderColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: OrderColors.border),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 32,
                  horizontalMargin: 24,
                  headingRowHeight: 56,
                  dataRowHeight: 80,
                  headingTextStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: OrderColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                  dividerThickness: 0,
                  columns: const [
                    DataColumn(label: Text('ORDER ID')),
                    DataColumn(label: Text('BUYER INFO')),
                    DataColumn(label: Text('TYPE')),
                    DataColumn(label: Text('QUANTITY')),
                    DataColumn(label: Text('TOTAL')),
                    DataColumn(label: Text('STATUS')),
                    DataColumn(label: Text('DATE')),
                    DataColumn(label: Text('ACTIONS')),
                  ],
                  rows:
                      orders.map((order) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                order.orderId,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: OrderColors.textPrimary,
                                  fontFamily: 'Roboto Mono',
                                ),
                              ),
                            ),
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    order.buyer.fullName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: OrderColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    order.buyer.phoneNumber,
                                    style: TextStyle(
                                      color: OrderColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: controller
                                      .getTypeColor(
                                        order.orderType,
                                        order.isUrgent,
                                      )
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: controller
                                        .getTypeColor(
                                          order.orderType,
                                          order.isUrgent,
                                        )
                                        .withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      order.isUrgent
                                          ? Iconsax.flash_1
                                          : Iconsax.clock,
                                      size: 14,
                                      color: controller.getTypeColor(
                                        order.orderType,
                                        order.isUrgent,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      order.isUrgent
                                          ? 'Urgent'
                                          : order.orderType.capitalizeFirst ??
                                              order.orderType,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: controller.getTypeColor(
                                          order.orderType,
                                          order.isUrgent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            DataCell(
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${order.quantity} × ${order.cylinderSize}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: OrderColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Cylinders',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: OrderColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Text(
                                'Rs ${order.pricing.grandTotal}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: OrderColors.accentGreen,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: controller
                                      .getStatusColor(order.status)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: controller
                                        .getStatusColor(order.status)
                                        .withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: controller.getStatusColor(
                                          order.status,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      order.status.capitalizeFirst ??
                                          order.status,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: controller.getStatusColor(
                                          order.status,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            DataCell(
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatDate(order.createdAt),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: OrderColors.textPrimary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    _formatTime(order.createdAt),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: OrderColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    onPressed:
                                        () => adminController.showOrderDetails(
                                          order.id,
                                        ),
                                    icon: Icon(Iconsax.eye, size: 20),
                                    tooltip: 'View Details',
                                    color: OrderColors.textSecondary,
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                  ),
                                  SizedBox(width: 16),
                                  PopupMenuButton(
                                    itemBuilder:
                                        (context) => [
                                          PopupMenuItem(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Iconsax.edit,
                                                  size: 18,
                                                  color: OrderColors.primary,
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  'Update Status',
                                                  style: TextStyle(
                                                    color:
                                                        OrderColors.textPrimary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            onTap:
                                                () => _showStatusDialog(order),
                                          ),
                                          PopupMenuItem(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Iconsax.scan,
                                                  size: 18,
                                                  color:
                                                      OrderColors.accentGreen,
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  'View QR Code',
                                                  style: TextStyle(
                                                    color:
                                                        OrderColors.textPrimary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            onTap: () => _showQRCode(order),
                                          ),
                                        ],
                                    icon: Icon(
                                      Iconsax.more,
                                      size: 20,
                                      color: OrderColors.textSecondary,
                                    ),
                                    padding: EdgeInsets.zero,
                                    elevation: 2,
                                    color: OrderColors.surface,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
              if (controller.filteredOrders.isNotEmpty) ...[
                Divider(height: 1, color: OrderColors.border),
                _buildPagination(),
              ],
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPagination() {
    final pagination = controller.ordersResponse.value?.data.pagination;
    if (pagination == null) return SizedBox();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Page ${pagination.currentPage} of ${pagination.totalPages}',
            style: TextStyle(color: OrderColors.textSecondary, fontSize: 13),
          ),
          Row(
            children: [
              IconButton(
                onPressed:
                    pagination.hasPrev
                        ? () => controller.fetchOrders(
                          page: pagination.currentPage - 1,
                        )
                        : null,
                icon: Icon(Iconsax.arrow_left_2, size: 20),
                color: OrderColors.textPrimary,
                disabledColor: OrderColors.textSecondary.withOpacity(0.3),
                padding: EdgeInsets.all(8),
                constraints: BoxConstraints(),
              ),
              SizedBox(width: 8),
              IconButton(
                onPressed:
                    pagination.hasNext
                        ? () => controller.fetchOrders(
                          page: pagination.currentPage + 1,
                        )
                        : null,
                icon: Icon(Iconsax.arrow_right_3, size: 20),
                color: OrderColors.textPrimary,
                disabledColor: OrderColors.textSecondary.withOpacity(0.3),
                padding: EdgeInsets.all(8),
                constraints: BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showStatusDialog(Order order) {
    final statuses = ['Pending', 'In Transit', 'Completed', 'Cancelled'];

    Get.defaultDialog(
      title: 'Update Order Status',
      titleStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: OrderColors.textPrimary,
      ),
      contentPadding: EdgeInsets.all(20),
      radius: 16,
      content: ValueListenableBuilder<String>(
        valueListenable: ValueNotifier(
          '',
        ), // just a dummy, real state is via map
        builder: (context, val, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Current Status: ${order.status}',
                style: TextStyle(
                  color: OrderColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 24),
              ...statuses.map((status) {
                final color = controller.getStatusColor(status);
                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: OrderColors.border),
                    ),
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getStatusIcon(status),
                        color: color,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      status,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: OrderColors.textPrimary,
                      ),
                    ),
                    onTap: () {
                      Get.back();
                      controller.updateOrderStatus(order.id, status);
                    },
                    tileColor: OrderColors.surface,
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  void _showQRCode(Order order) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Order QR Code',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Replace with actual QR code widget
                  Icon(Icons.qr_code_scanner, size: 100, color: Colors.blue),
                  SizedBox(height: 20),
                  Text(
                    order.orderId,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto Mono',
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('Scan to verify order details'),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: Get.back,
              child: Text('Close'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'in transit':
        return Icons.local_shipping;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
