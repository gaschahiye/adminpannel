// admin/views/sellers_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../Controller/adminController.dart';
import '../Controller/sellercontroller.dart';
import '../Models/Sellermodel.dart';
import 'SellerDetails.dart';

import 'SellerColors.dart';

// SellerColors is now imported from SellerColors.dart

class SellersView extends StatelessWidget {
  final SellersController controller = Get.put(SellersController());
  final AdminController adminController = Get.find<AdminController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (adminController.isViewingSellerDetails.value) {
        final seller = controller.getSellerById(
          adminController.selectedSellerId.value,
        );
        return seller != null
            ? SellerDetailsView(sellerId: seller.sId)
            : Center(child: Text('Seller not found'));
      }
      return Scaffold(
        backgroundColor: SellerColors.background,
        body: _buildMainView(),
      );
    });
  }

  Widget _buildMainView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildStatsGrid(),
          const SizedBox(height: 32),
          _buildMainCard(),
          if (controller.pagination != null &&
              (controller.pagination!.totalPages ?? 0) > 1)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: _buildPagination(),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sellers',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: SellerColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage your seller partners and applications',
              style: TextStyle(fontSize: 14, color: SellerColors.textSecondary),
            ),
          ],
        ),
        Row(
          children: [
            Obx(
              () =>
                  controller.isLoading.value
                      ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: SellerColors.textSecondary,
                        ),
                      )
                      : IconButton(
                        onPressed: () => controller.fetchSellers(),
                        icon: Icon(
                          Iconsax.refresh,
                          size: 20,
                          color: SellerColors.textPrimary,
                        ),
                        tooltip: 'Refresh',
                      ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: SellerColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IntrinsicWidth(
                child: Row(
                  children: [
                    Icon(Iconsax.add, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Add Seller',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int cols =
            constraints.maxWidth < 640
                ? 1
                : constraints.maxWidth < 1024
                ? 2
                : 4;

        return GridView.count(
          crossAxisCount: cols,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: cols == 1 ? 2.8 : 1.8,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard(
              title: 'Total Sellers',
              value: controller.totalSellers.toString(),
              icon: Iconsax.shop,
              color: SellerColors.accentBlue,
            ),
            _buildStatCard(
              title: 'Pending Approval',
              value: controller.pendingCount.toString(),
              icon: Iconsax.clock,
              color: SellerColors.accentOrange,
            ),
            _buildStatCard(
              title: 'Active Sellers',
              value: controller.approvedCount.toString(),
              icon: Iconsax.verify,
              color: SellerColors.accentGreen,
            ),
            _buildStatCard(
              title: 'Rejected',
              value: controller.rejectedCount.toString(),
              icon: Iconsax.close_circle,
              color: SellerColors.accentRed,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SellerColors.surface,
        border: Border.all(color: SellerColors.border),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            offset: Offset(0, 1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: SellerColors.textSecondary,
                ),
              ),
              Icon(
                icon,
                size: 20,
                color: SellerColors.textSecondary.withOpacity(0.7),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: SellerColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      decoration: BoxDecoration(
        color: SellerColors.surface,
        border: Border.all(color: SellerColors.border),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildSearchBar()),
                    SizedBox(width: 16),
                    _buildStatusFilter(),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: SellerColors.border),
          _buildSellersTable(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: SellerColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SellerColors.border),
      ),
      child: TextField(
        onChanged: (v) => controller.searchQuery.value = v,
        style: TextStyle(fontSize: 14, color: SellerColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search sellers...',
          hintStyle: TextStyle(color: SellerColors.textSecondary),
          prefixIcon: Icon(
            Iconsax.search_normal,
            size: 16,
            color: SellerColors.textSecondary,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Obx(
      () => Container(
        height: 40,
        padding: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: SellerColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: SellerColors.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.selectedStatus.value,
            onChanged: (v) => controller.selectedStatus.value = v!,
            icon: Icon(
              Iconsax.arrow_down_1,
              size: 16,
              color: SellerColors.textSecondary,
            ),
            style: TextStyle(fontSize: 14, color: SellerColors.textPrimary),
            items:
                controller.statusOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildSellersTable() {
    return Obx(() {
      if (controller.isLoading.value && controller.sellersList.isEmpty) {
        return Container(
          height: 300,
          child: Center(
            child: CircularProgressIndicator(color: SellerColors.textPrimary),
          ),
        );
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return Container(
          height: 300,
          child: Center(
            child: Text(
              controller.errorMessage.value,
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      }

      final sellers = controller.filteredSellers;
      if (sellers.isEmpty) {
        return Container(
          height: 300,
          child: Center(
            child: Text(
              'No sellers found',
              style: TextStyle(color: SellerColors.textSecondary),
            ),
          ),
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 800,
          ), // Ensure min width for table
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(SellerColors.background),
            dataRowColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.hovered))
                return SellerColors.background.withOpacity(0.5);
              return SellerColors.surface;
            }),
            dividerThickness: 1,
            horizontalMargin: 24,
            columnSpacing: 40,

            columns: [
              DataColumn(label: _buildHeaderCell('BUSINESS')),
              DataColumn(label: _buildHeaderCell('CONTACT')),
              DataColumn(label: _buildHeaderCell('STATUS')),
              DataColumn(label: _buildHeaderCell('LOCATION')),
              DataColumn(label: _buildHeaderCell('JOINED')),
              DataColumn(label: _buildHeaderCell('ACTIONS')),
            ],
            rows:
                sellers.map((seller) {
                  return DataRow(
                    cells: [
                      DataCell(_buildBusinessCell(seller)),
                      DataCell(_buildContactCell(seller)),
                      DataCell(_buildStatusBadge(seller.sellerStatus)),
                      DataCell(
                        Text(
                          controller.getLocationString(seller),
                          style: TextStyle(
                            fontSize: 13,
                            color: SellerColors.textSecondary,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          controller.formatDate(seller.createdAt),
                          style: TextStyle(
                            fontSize: 13,
                            color: SellerColors.textSecondary,
                          ),
                        ),
                      ),
                      DataCell(_buildActions(seller)),
                    ],
                  );
                }).toList(),
          ),
        ),
      );
    });
  }

  Widget _buildHeaderCell(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: SellerColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildBusinessCell(Sellers seller) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: SellerColors.primary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(Iconsax.shop, color: Colors.white, size: 16),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              seller.businessName ?? 'Unknown',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: SellerColors.textPrimary,
              ),
            ),
            if (seller.orgaLicenseNumber != null)
              Text(
                'Lic: ${seller.orgaLicenseNumber}',
                style: TextStyle(
                  fontSize: 11,
                  color: SellerColors.textSecondary,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactCell(Sellers seller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          seller.phoneNumber ?? '-',
          style: TextStyle(fontSize: 13, color: SellerColors.textPrimary),
        ),
        Text(
          seller.email ?? '-',
          style: TextStyle(fontSize: 12, color: SellerColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color bg;
    Color text;
    String label = status ?? 'Unknown';

    switch (label.toLowerCase()) {
      case 'approved':
        bg = Color(0xFFDCFCE7); // Green 100
        text = Color(0xFF15803D); // Green 700
        break;
      case 'pending':
        bg = Color(0xFFFEF3C7); // Amber 100
        text = Color(0xFFB45309); // Amber 700
        break;
      case 'rejected':
        bg = Color(0xFFFEE2E2); // Red 100
        text = Color(0xFFB91C1C); // Red 700
        break;
      default:
        bg = Color(0xFFF1F5F9); // Slate 100
        text = Color(0xFF64748B); // Slate 500
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActions(Sellers seller) {
    return Row(
      children: [
        if (seller.sellerStatus != 'Approved' &&
            seller.sellerStatus != 'approved')
          IconButton(
            icon: Icon(
              Iconsax.tick_circle,
              color: SellerColors.accentGreen,
              size: 18,
            ),
            onPressed: () => _updateStatus(seller, 'approved'),
            tooltip: 'Approve',
          ),
        if (seller.sellerStatus != 'Rejected' &&
            seller.sellerStatus != 'rejected')
          IconButton(
            icon: Icon(
              Iconsax.close_circle,
              color: SellerColors.accentRed,
              size: 18,
            ),
            onPressed: () => _updateStatus(seller, 'rejected'),
            tooltip: 'Reject',
          ),

        PopupMenuButton(
          icon: Icon(Iconsax.more, size: 16, color: SellerColors.textSecondary),
          elevation: 2,
          color: Colors.white,
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Iconsax.eye, size: 16),
                      SizedBox(width: 8),
                      Text("View Details", style: TextStyle(fontSize: 13)),
                    ],
                  ),
                  onTap: () {
                    Future.delayed(Duration.zero, () {
                      adminController.showSellerDetails(seller.sId!);
                    });
                  },
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Iconsax.trash, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        "Delete",
                        style: TextStyle(fontSize: 13, color: Colors.red),
                      ),
                    ],
                  ),
                  onTap: () => _deleteSeller(seller),
                ),
              ],
        ),
      ],
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed:
              (controller.pagination?.currentPage ?? 1) > 1
                  ? () => controller.fetchSellers(
                    page: (controller.pagination!.currentPage!) - 1,
                  )
                  : null,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: SellerColors.border),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Text(
            'Previous',
            style: TextStyle(color: SellerColors.textPrimary),
          ),
        ),
        SizedBox(width: 16),
        Text(
          'Page ${controller.pagination?.currentPage ?? 1} of ${controller.pagination?.totalPages ?? 1}',
          style: TextStyle(color: SellerColors.textSecondary, fontSize: 13),
        ),
        SizedBox(width: 16),
        OutlinedButton(
          onPressed:
              (controller.pagination?.hasNext ?? false)
                  ? () => controller.fetchSellers(
                    page: (controller.pagination!.currentPage!) + 1,
                  )
                  : null,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: SellerColors.border),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Text(
            'Next',
            style: TextStyle(color: SellerColors.textPrimary),
          ),
        ),
      ],
    );
  }

  void _updateStatus(Sellers seller, String status) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Confirm Action'),
        content: Text(
          'Are you sure you want to mark ${seller.businessName} as $status?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: SellerColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SellerColors.primary,
            ),
            onPressed: () {
              Get.back();
              controller.updateSellerStatus(seller.sId!, status);
            },
            child: Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteSeller(Sellers seller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Delete Seller'),
        content: Text(
          'Are you sure you want to delete ${seller.businessName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: SellerColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back();
              controller.deleteSeller(seller.sId!);
            },
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
