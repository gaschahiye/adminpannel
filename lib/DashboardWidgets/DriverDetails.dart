// admin/views/driver_details_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../Controller/DriverController.dart';
import '../Controller/adminController.dart';
import '../Models/DriverModel.dart';
import '../widgets/animations/fade_in_slide.dart';
import 'DriverColors.dart';

class DriverDetailsView extends StatelessWidget {
  final Drivers driver;
  final DriversController driversController = Get.find();
  final AdminController adminController = Get.find();

  DriverDetailsView({required this.driver});

  @override
  Widget build(BuildContext context) {
    final stats = driver.stats ?? Stats();
    final deliveryRate =
        stats.deliveredOrders != null &&
                stats.totalOrders != null &&
                stats.totalOrders! > 0
            ? (stats.deliveredOrders! / stats.totalOrders! * 100)
            : 0.0;

    return Scaffold(
      backgroundColor: DriverColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 32),
            FadeInSlide(delay: 0.1, child: _buildProfileCard()),
            SizedBox(height: 32),
            FadeInSlide(
              delay: 0.2,
              child: _buildStatsGrid(stats, deliveryRate),
            ),
            SizedBox(height: 32),
            FadeInSlide(delay: 0.3, child: _buildDetailedContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            adminController.hideDriverDetails();
          },
          icon: Icon(Icons.arrow_back, color: DriverColors.textSecondary),
          tooltip: 'Back',
        ),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Driver Management',
                  style: TextStyle(
                    color: DriverColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  ' / Details',
                  style: TextStyle(
                    color: DriverColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              driver.fullName ?? 'Driver Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: DriverColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DriverColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DriverColors.border),
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
              color: DriverColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DriverColors.border),
            ),
            child: Center(
              child: Text(
                driver.fullName != null && driver.fullName!.isNotEmpty
                    ? driver.fullName!.substring(0, 1).toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: DriverColors.textSecondary,
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
                      driver.fullName ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: DriverColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 12),
                    _buildStatusBadge(driver.isActive),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    _buildIconText(
                      Iconsax.call,
                      driver.phoneNumber ?? 'N/A',
                      DriverColors.textSecondary,
                    ),
                    SizedBox(width: 16),
                    _buildIconText(
                      Iconsax.sms,
                      driver.email ?? 'N/A',
                      DriverColors.textSecondary,
                    ),
                    SizedBox(width: 16),
                    _buildIconText(
                      Iconsax.calendar_1,
                      'Joined ${driversController.formatDate(driver.createdAt)}',
                      DriverColors.textSecondary,
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

  Widget _buildStatusBadge(bool? isActive) {
    Color bg = isActive == true ? Color(0xFFDCFCE7) : Color(0xFFFEE2E2);
    Color text = isActive == true ? Color(0xFF15803D) : Color(0xFFB91C1C);
    String label = isActive == true ? 'Online' : 'Offline';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
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

  Widget _buildStatsGrid(Stats stats, double deliveryRate) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.8,
      children: [
        _buildStatCard(
          title: 'Total Orders',
          value: stats.totalOrders?.toString() ?? '0',
          icon: Iconsax.shopping_cart,
          color: DriverColors.accentBlue,
        ),
        _buildStatCard(
          title: 'Delivered',
          value: stats.deliveredOrders?.toString() ?? '0',
          icon: Iconsax.tick_circle,
          color: DriverColors.accentGreen,
        ),
        _buildStatCard(
          title: 'Delivery Rate',
          value: '${deliveryRate.toStringAsFixed(1)}%',
          icon: Iconsax.chart_2,
          color: DriverColors.accentPurple,
          progress: deliveryRate / 100,
        ),
        _buildStatCard(
          title: 'Rating',
          value: stats.averageRating?.toStringAsFixed(1) ?? '0.0',
          icon:
              Iconsax
                  .star, // Keep filled star if possible, Iconsax.star is outline usually
          color: DriverColors.accentOrange,
          subtitle: '${stats.ratingCount ?? 0} reviews',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String subtitle = '',
    double? progress,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DriverColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DriverColors.border),
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              Spacer(),
              if (progress != null)
                CircularPercentIndicator(
                  radius: 18,
                  lineWidth: 3,
                  percent: progress.clamp(0.0, 1.0),
                  center: Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: DriverColors.textPrimary,
                    ),
                  ),
                  progressColor: color,
                  backgroundColor: color.withOpacity(0.1),
                ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: DriverColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: DriverColors.textSecondary,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                SizedBox(width: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildSectionCard(
            'Personal & Vehicle Information',
            Column(
              children: [
                _buildInfoGrid(),
                SizedBox(height: 24),
                Divider(color: DriverColors.border),
                SizedBox(height: 24),
                _buildVehicleGrid(),
              ],
            ),
          ),
        ),
        SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: _buildSectionCard(
            'Status Management',
            _buildStatusManagement(),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(String title, Widget content) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DriverColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DriverColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: DriverColors.textPrimary,
            ),
          ),
          Divider(height: 32, color: DriverColors.border),
          content,
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        _buildInfoItem('Full Name', driver.fullName ?? 'N/A'),
        _buildInfoItem('CNIC', driver.cnic ?? 'N/A'),
        _buildInfoItem('Phone', driver.phoneNumber ?? 'N/A'),
        _buildInfoItem('Email', driver.email ?? 'N/A'),
      ],
    );
  }

  Widget _buildVehicleGrid() {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        _buildInfoItem('Vehicle Number', driver.vehicleNumber ?? 'N/A'),
        _buildInfoItem('Zone', driver.zoneObject?.zoneName ?? 'Not Assigned'),
        _buildInfoItem('Driver Status', driver.driverStatus ?? 'N/A'),
        _buildInfoItem(
          'Auto Assign',
          driver.autoAssignOrders == true ? 'Enabled' : 'Disabled',
        ),
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
            style: TextStyle(fontSize: 12, color: DriverColors.textSecondary),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: DriverColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Status',
          style: TextStyle(fontSize: 12, color: DriverColors.textSecondary),
        ),
        SizedBox(height: 8),
        _buildStatusBadge(driver.isActive),
        SizedBox(height: 24),
        Text(
          'Actions',
          style: TextStyle(fontSize: 12, color: DriverColors.textSecondary),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Get.defaultDialog(...)
              // Logic to toggle status using controller
            },
            icon: Icon(Iconsax.refresh, size: 16),
            label: Text('Toggle Status'),
            style: OutlinedButton.styleFrom(
              foregroundColor: DriverColors.textPrimary,
              side: BorderSide(color: DriverColors.border),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
