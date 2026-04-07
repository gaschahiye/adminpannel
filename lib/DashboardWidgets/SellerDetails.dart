// admin/views/seller_details_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../Controller/SellerDetailsController.dart';
import '../Controller/adminController.dart';
import '../Controller/sellercontroller.dart';
import '../Models/SingleSellerModel.dart';

import 'SellerColors.dart';

// SellerColors is now imported from SellerColors.dart

class SellerDetailsView extends StatelessWidget {
  final String? sellerId;

  SellerDetailsView({this.sellerId});

  final SellerDetailsController detailsController = Get.put(
    SellerDetailsController(),
  );
  final AdminController adminController = Get.find<AdminController>();
  final SellersController sellersController = Get.find<SellersController>();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (sellerId != null) {
        detailsController.fetchSellerDetails(sellerId!);
      } else if (adminController.selectedSellerId.value.isNotEmpty) {
        detailsController.fetchSellerDetails(
          adminController.selectedSellerId.value,
        );
      }
    });

    return Scaffold(
      backgroundColor: SellerColors.background,
      body: Obx(() {
        final seller = detailsController.seller;
        final isLoading = detailsController.isLoading.value;
        final error = detailsController.errorMessage.value;

        if (isLoading && seller == null) {
          return Center(child: CircularProgressIndicator());
        }

        if (error.isNotEmpty) {
          return _buildErrorState();
        }

        if (seller == null) {
          return Center(child: Text('Seller not found'));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(seller),
              SizedBox(height: 24),
              _buildProfileCard(seller),
              SizedBox(height: 24),
              _buildStatsGrid(seller),
              SizedBox(height: 24),
              _buildDetailedContent(seller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: SellerColors.accentRed),
          SizedBox(height: 16),
          Text(
            detailsController.errorMessage.value,
            style: TextStyle(color: SellerColors.textSecondary),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (sellerId != null) {
                detailsController.fetchSellerDetails(sellerId!);
              } else if (adminController.selectedSellerId.value.isNotEmpty) {
                detailsController.fetchSellerDetails(
                  adminController.selectedSellerId.value,
                );
              }
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Seller seller) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            adminController.hideSellerDetails();
            detailsController.clearDetails();
          },
          icon: Icon(Icons.arrow_back, color: SellerColors.textSecondary),
          tooltip: 'Back',
        ),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Seller Management',
                  style: TextStyle(
                    color: SellerColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  ' / Details',
                  style: TextStyle(
                    color: SellerColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              seller.businessName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: SellerColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Spacer(),
        OutlinedButton.icon(
          onPressed: () {
            if (sellerId != null) {
              detailsController.fetchSellerDetails(sellerId!);
            } else if (adminController.selectedSellerId.value.isNotEmpty) {
              detailsController.fetchSellerDetails(
                adminController.selectedSellerId.value,
              );
            }
          },
          icon: Icon(Icons.refresh, size: 16, color: SellerColors.textPrimary),
          label: Text(
            'Refresh',
            style: TextStyle(color: SellerColors.textPrimary),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: SellerColors.border),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(Seller seller) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SellerColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SellerColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: SellerColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SellerColors.border),
            ),
            child: Center(
              child: Text(
                seller.businessName.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: SellerColors.textSecondary,
                ),
              ),
            ),
          ),
          SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      seller.businessName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: SellerColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 12),
                    _buildStatusBadge(seller.sellerStatus),
                    if (seller.isVerified) ...[
                      SizedBox(width: 8),
                      Icon(
                        Iconsax.verify,
                        size: 18,
                        color: SellerColors.accentBlue,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    _buildIconText(
                      Iconsax.call,
                      seller.phoneNumber,
                      SellerColors.textSecondary,
                    ),
                    SizedBox(width: 16),
                    _buildIconText(
                      Iconsax.sms,
                      seller
                          .role, // Assuming role is email placeholder based on previous code
                      SellerColors.textSecondary,
                    ),
                    SizedBox(width: 16),
                    _buildIconText(
                      Iconsax.calendar_1,
                      'Joined ${detailsController.formatDate(seller.createdAt)}',
                      SellerColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    switch (status.toLowerCase()) {
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
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: text,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        SizedBox(width: 6),
        Text(text, style: TextStyle(color: color, fontSize: 13)),
      ],
    );
  }

  Widget _buildStatsGrid(Seller seller) {
    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      childAspectRatio: 1.8,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          'Total Orders',
          '${seller.stats.totalOrders}',
          Iconsax.shopping_bag,
          SellerColors.accentBlue,
        ),
        _buildStatCard(
          'Total Revenue',
          'Rs.${seller.stats.totalRevenue}',
          Iconsax.money_tick,
          SellerColors.accentGreen,
        ),
        _buildStatCard(
          'Completed',
          '${seller.stats.completedOrders}',
          Iconsax.tick_circle,
          SellerColors
              .accentBlue, // Keeping blue for consistency or maybe distinct?
        ),
        _buildStatCard(
          'Rating',
          '${seller.rating.average}',
          Iconsax.star_1,
          SellerColors.accentOrange,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color accentColor,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SellerColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SellerColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: accentColor),
              ),
              Spacer(),
              // Icon(Iconsax.arrow_right_3, size: 16, color: SellerColors.textSecondary),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: SellerColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 13, color: SellerColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedContent(Seller seller) {
    return Column(
      children: [
        // Business Info & Documents
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildSectionCard(
                'Business Information',
                _buildBusinessInfoGrid(seller),
              ),
            ),
            SizedBox(width: 24),
            Expanded(
              flex: 1,
              child: _buildSectionCard(
                'Documents',
                _buildDocumentsList(seller),
              ),
            ),
          ],
        ),
        SizedBox(height: 24),

        // Warehouse Locations
        if (seller.locations.isNotEmpty)
          _buildSectionCard(
            'Warehouse Locations (${seller.locations.length})',
            _buildLocationsList(seller),
          ),

        SizedBox(height: 24),

        // Inventory
        if (seller.inventory.isNotEmpty)
          _buildSectionCard('Inventory Overview', _buildInventoryGrid(seller)),
      ],
    );
  }

  Widget _buildSectionCard(String title, Widget content) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SellerColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SellerColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: SellerColors.textPrimary,
            ),
          ),
          Divider(height: 32, color: SellerColors.border),
          content,
        ],
      ),
    );
  }

  Widget _buildBusinessInfoGrid(Seller seller) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        _buildInfoItem('License Number', seller.orgaLicenseNumber),
        _buildInfoItem('NTN Number', seller.ntnNumber),
        _buildInfoItem(
          'License Expiry',
          seller.orgaExpDate != null
              ? detailsController.formatDate(seller.orgaExpDate)
              : 'N/A',
        ),
        _buildInfoItem('Language', seller.language),
        _buildInfoItem(
          'Auto Assign',
          seller.autoAssignOrders ? 'Enabled' : 'Disabled',
        ),
        _buildInfoItem('Driver Status', seller.driverStatus),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: SellerColors.textSecondary),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: SellerColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList(Seller seller) {
    return Column(
      children: [
        _buildDocumentTile(
          'Business License',
          seller.orgaLicenseFile,
          Iconsax.document_text,
        ),
      ],
    );
  }

  Widget _buildDocumentTile(String name, String url, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: SellerColors.border),
        borderRadius: BorderRadius.circular(8),
        color: SellerColors.background,
      ),
      child: Row(
        children: [
          Icon(icon, color: SellerColors.textSecondary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: SellerColors.textPrimary,
              ),
            ),
          ),
          if (url.isNotEmpty)
            IconButton(
              onPressed: () {
                Get.dialog(
                  Dialog(
                    child: Stack(
                      children: [
                        InteractiveViewer(child: Image.network(url)),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: IconButton(
                            icon: Icon(Icons.close, color: Colors.black),
                            onPressed: () => Get.back(),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              icon: Icon(Iconsax.eye, size: 18, color: SellerColors.accentBlue),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationsList(Seller seller) {
    return Column(
      children:
          seller.locations.map((loc) {
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: SellerColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          loc.isActive
                              ? SellerColors.accentGreen.withOpacity(0.1)
                              : SellerColors.accentRed.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.location,
                      size: 20,
                      color:
                          loc.isActive
                              ? SellerColors.accentGreen
                              : SellerColors.accentRed,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.warehouseName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: SellerColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '${loc.address}, ${loc.city}',
                          style: TextStyle(
                            fontSize: 13,
                            color: SellerColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusPill(loc.isActive),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildInventoryGrid(Seller seller) {
    return Column(
      children:
          seller.inventory.map((inv) {
            return Container(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: SellerColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        inv.location,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: SellerColors.textPrimary,
                        ),
                      ),
                      _buildStatusPill(inv.isActive),
                    ],
                  ),
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        inv.cylinders.entries.map((e) {
                          return Chip(
                            label: Text('${e.key}: ${e.value.quantity} Units'),
                            backgroundColor: SellerColors.background,
                            side: BorderSide(color: SellerColors.border),
                            labelStyle: TextStyle(
                              color: SellerColors.textSecondary,
                              fontSize: 12,
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildStatusPill(bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color:
            isActive
                ? SellerColors.accentGreen.withOpacity(0.1)
                : SellerColors.accentRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isActive ? SellerColors.accentGreen : SellerColors.accentRed,
        ),
      ),
    );
  }
}
