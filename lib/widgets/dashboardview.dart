// admin/views/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../Controller/DashboardController.dart';
import '../Controller/adminController.dart';
import 'animations/fade_in_slide.dart';

// Tailwind-like Color Palette (Slate/Zinc)
class AppColors {
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color primary = Color(0xFF0F172A); // Slate 900
  static const Color accentBlue = Color(0xFF3B82F6); // Blue 500
  static const Color accentGreen = Color(0xFF10B981); // Emerald 500
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentOrange = Color(0xFFF59E0B);
}

class DashboardView extends StatelessWidget {
  final DashboardController controller = Get.find();
  final AdminController adminController = Get.find<AdminController>();

  @override
  Widget build(BuildContext context) {
    // If controller is not initialized, it will throw an error.
    // Ensure DashboardController is put before this view is built.

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        
        if (controller.errorMessage.value.isNotEmpty && controller.stats == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.info_circle, size: 48, color: AppColors.accentOrange),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    controller.errorMessage.value, 
                    style: TextStyle(color: AppColors.textPrimary), 
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: controller.refreshData, 
                  child: Text('Retry Connection'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                )
              ]
            )
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildStatsGrid(),
              const SizedBox(height: 32),
              _buildMainCharts(),
              const SizedBox(height: 32),
              FadeInSlide(delay: 0.7, child: _buildRecentActivities()),
            ],
          ),
        );
      }),
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
              'Dashboard',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Overview of your business performance',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
        _buildHeaderAction(),
      ],
    );
  }

  Widget _buildHeaderAction() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Iconsax.calendar_1,
                size: 16,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 8),
              Text(
                'Last 30 Days',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Iconsax.arrow_down_1,
                size: 14,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
        SizedBox(width: 12),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Iconsax.export_1, color: Colors.white, size: 18),
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

        return Obx(
          () => GridView.count(
            crossAxisCount: cols,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: cols == 1 ? 2.8 : 1.8,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              FadeInSlide(
                duration: Duration(milliseconds: 600),
                delay: 0.1,
                child: _buildStatCard(
                  title: 'Total Revenue',
                  value: controller.formatCurrency(controller.totalRevenue),
                  trend: '+12.5%',
                  trendUp: true,
                  icon: Iconsax.money_tick,
                  color: AppColors.accentGreen,
                ),
              ),
              FadeInSlide(
                duration: Duration(milliseconds: 600),
                delay: 0.2,
                child: _buildStatCard(
                  title: 'Total Orders',
                  value: controller.totalOrders.toString(),
                  trend: '+8.2%',
                  trendUp: true,
                  icon: Iconsax.shopping_cart,
                  color: AppColors.accentBlue,
                ),
              ),
              FadeInSlide(
                duration: Duration(milliseconds: 600),
                delay: 0.3,
                child: _buildStatCard(
                  title: 'Total Sellers',
                  value: controller.totalSellers.toString(),
                  trend: '+2.4%',
                  trendUp: true,
                  icon: Iconsax.shop,
                  color: AppColors.accentPurple,
                ),
              ),
              FadeInSlide(
                duration: Duration(milliseconds: 600),
                delay: 0.4,
                child: _buildStatCard(
                  title: 'Active Drivers',
                  value: controller.activeDrivers.toString(),
                  trend: '-1.1%',
                  trendUp: false,
                  icon: Iconsax.car,
                  color: AppColors.accentOrange,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String trend,
    required bool trendUp,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
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
                  color: AppColors.textSecondary,
                ),
              ),
              Icon(
                icon,
                size: 20,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trendUp ? Color(0xFFDCFCE7) : Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      trendUp ? Iconsax.arrow_up_3 : Iconsax.arrow_down,
                      size: 10,
                      color: trendUp ? Color(0xFF15803D) : Color(0xFFB91C1C),
                    ),
                    SizedBox(width: 4),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: trendUp ? Color(0xFF15803D) : Color(0xFFB91C1C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainCharts() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 1024;

        return Obx(
          () =>
              isMobile
                  ? Column(
                    children: [
                      FadeInSlide(delay: 0.5, child: _buildOrderTrendsChart()),
                      SizedBox(height: 32),
                      FadeInSlide(delay: 0.6, child: _buildOrderStatusList()),
                    ],
                  )
                  : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: FadeInSlide(
                          delay: 0.5,
                          child: _buildOrderTrendsChart(),
                        ),
                      ),
                      SizedBox(width: 32),
                      Expanded(
                        flex: 1,
                        child: FadeInSlide(
                          delay: 0.6,
                          child: _buildOrderStatusList(),
                        ),
                      ),
                    ],
                  ),
        );
      },
    );
  }

  Widget _buildOrderTrendsChart() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Trends',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Icon(Iconsax.more, color: AppColors.textSecondary, size: 18),
            ],
          ),
          SizedBox(height: 32),
          Container(
            height: 300,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 200, // Adjust based on data scale
                  getDrawingHorizontalLine:
                      (value) =>
                          FlLine(color: AppColors.border, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ), // Cleaning up axis
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        // Assuming value corresponds to month index (0-11)
                        final months = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                          'Aug',
                          'Sep',
                          'Oct',
                          'Nov',
                          'Dec',
                        ];
                        if (value >= 0 && value < months.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              months[value.toInt()],
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups:
                    controller.monthlyOrderData.map((data) {
                      // Robustly determine the correct month index (0-11)
                      final int monthIndex = _getMonthIndex(data.month);

                      return BarChartGroupData(
                        x: monthIndex,
                        barRods: [
                          BarChartRodData(
                            toY: data.orders?.toDouble() ?? 0,
                            color: AppColors.primary,
                            width: 20,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getMonthIndex(String? monthStr) {
    if (monthStr == null || monthStr.isEmpty) return 0;

    // 1. Try parsing as DateTime (e.g., "2024-02-01", "2024-02")
    try {
      final date = DateTime.parse(monthStr);
      return date.month - 1; // DateTime.month is 1-12, chart expects 0-11
    } catch (_) {}

    // 2. Try parsing as full month name or short name
    final lower = monthStr.toLowerCase();
    const months = [
      'jan',
      'feb',
      'mar',
      'apr',
      'may',
      'jun',
      'jul',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec',
    ];

    for (int i = 0; i < months.length; i++) {
      if (lower.startsWith(months[i])) {
        return i;
      }
    }

    // 3. Try parsing as integer string "1", "02"
    final intVal = int.tryParse(monthStr);
    if (intVal != null && intVal >= 1 && intVal <= 12) {
      return intVal - 1;
    }

    return 0; // Default to Jan if all parsing fails
  }

  Widget _buildOrderStatusList() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
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
        children: [
          Text(
            'Order Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: controller.orderStatusData.length,
            separatorBuilder: (c, i) => SizedBox(height: 16),
            itemBuilder: (context, index) {
              final status = controller.orderStatusData[index];
              // Calculate percentage broadly for demo
              double percentage =
                  (status.count ?? 0) /
                  (controller.totalOrders == 0 ? 1 : controller.totalOrders);
              if (percentage > 1.0) percentage = 1.0;

              Color statusColor = AppColors.textSecondary;
              if (status.status == 'Completed')
                statusColor = AppColors.accentGreen;
              if (status.status == 'Pending')
                statusColor = AppColors.accentOrange;
              if (status.status == 'Refill') statusColor = AppColors.accentBlue;

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: statusColor,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            status.status ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${status.count}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage,
                      minHeight: 6,
                      backgroundColor: AppColors.background,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activities',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),

            ],
          ),
          SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: controller.recentNotifications.length,
            separatorBuilder:
                (c, i) => Divider(height: 32, color: AppColors.border),
            itemBuilder: (context, index) {
              final notification = controller.recentNotifications[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.notification,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.message ?? 'No message',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          timeago.format(
                            DateTime.parse(
                              notification.createdAt ??
                                  DateTime.now().toString(),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
