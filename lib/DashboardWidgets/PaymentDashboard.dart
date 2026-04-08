import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Controller/PaymentController.dart';
import '../Models/payment_models.dart';
import '../theme/theme.dart';
import '../widgets/SectionHeader.dart';
import 'PaymentServiceCard.dart';
import 'PaymentTabel.dart';

class PaymentsView extends GetView<PaymentController> {
  const PaymentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;
    final isTablet = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          // Background Gradient Layer
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.5,
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              // Premium Header Section
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 40 : 20,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg.withOpacity(0.8),
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.borderColor.withOpacity(0.5),
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Payment Management',
                                  style: AppTheme.headlineLarge.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1,
                                    fontSize: isDesktop ? 32 : 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Live Status Indicator
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF10B981,
                                      ).withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF10B981),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'LIVE',
                                        style: TextStyle(
                                          color: const Color(0xFF10B981),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Text(
                            //   'Elite Ledger System • Real-time reconciliations and settlements',
                            //   style: AppTheme.bodyMedium.copyWith(
                            //     color: AppTheme.textSecondary.withOpacity(0.6),
                            //     fontWeight: FontWeight.w500,
                            //     letterSpacing: 0.2,
                            //   ),
                            // ),
                          ],
                        ),
                        const Spacer(),
                        /*
                        _ActionButton(
                          icon: Icons.table_view_rounded,
                          label: 'Export Ledger',
                          onPressed: () => controller.exportLedger(),
                          color: const Color(0xFF10B981),
                        ),
                        */
                      ],
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : 16,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Cards
                      Obx(
                        () =>
                            isDesktop
                                ? _buildDesktopSummaryGrid(
                                  controller.stats.value,
                                )
                                : isTablet
                                ? _buildTabletSummaryGrid(
                                  controller.stats.value,
                                )
                                : _buildMobileSummaryGrid(
                                  controller.stats.value,
                                ),
                      ),

                      const SizedBox(height: AppTheme.spacingXl),

                      // Payments Section
                      SectionHeader(
                        title: 'Ledger',
                        subtitle: 'Transaction history',
                      ),

                      const SizedBox(height: AppTheme.spacingLg),

                      // Search & Filter Row
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppTheme.cardBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.borderColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextField(
                                onChanged: controller.onSearchChanged,
                                style: AppTheme.bodyMedium,
                                decoration: InputDecoration(
                                  hintText: 'Search by seller, order ID...',
                                  hintStyle: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.textSecondary.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    color: AppTheme.primaryColor.withOpacity(
                                      0.7,
                                    ),
                                    size: 20,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Obx(
                            () => _FilterDropdown(
                              label: 'Status',
                              value: controller.selectedStatus.value,
                              items: [
                                'all',
                                'pending',
                                'collected',
                                'completed',
                                'failed',
                              ],
                              onChanged:
                                  (v) => controller.applyFilter(status: v),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Obx(
                            () => _FilterDropdown(
                              label: 'Type',
                              value: controller.selectedType.value,
                              items: ['all', 'sale', 'refund'],
                              onChanged: (v) => controller.applyFilter(type: v),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppTheme.spacingLg),

                      // Payments Table
                      Obx(
                        () => PaymentDataTable(
                          payments: controller.payments,
                          isLoading: controller.isLoading.value,
                          onClearPayment:
                              (payment, {referenceId, notes}) =>
                                  controller.clearPayment(
                                    payment,
                                    referenceId: referenceId,
                                    notes: notes,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSummaryGrid(PaymentSummary stats) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 5,
      childAspectRatio: 0.9,
      crossAxisSpacing: AppTheme.spacingLg,
      mainAxisSpacing: AppTheme.spacingLg,
      children: [
        PaymentSummaryCard(
          title: 'Total Pending',
          amount: stats.totalPending,
          subtitle: 'Awaiting clearance',
          icon: Icons.pending_actions,
          color: AppTheme.warningColor,
          onTap: () => controller.applyFilter(status: 'pending'),
        ),
        PaymentSummaryCard(
          title: 'Collected (Holding)',
          amount: stats.collectedAmount,
          subtitle: '${stats.collectedCount} collected refunds',
          icon: Icons.account_balance_wallet,
          color: const Color(0xFFD97706), // Amber
          onTap: () => controller.applyFilter(status: 'collected'),
        ),
        PaymentSummaryCard(
          title: 'Fully Cleared',
          amount: stats.clearedAmount,
          subtitle: 'Completed transactions',
          icon: Icons.check_circle,
          color: const Color(0xFF10B981), // Success green
          onTap: () => controller.applyFilter(status: 'completed'),
        ),
        PaymentSummaryCard(
          title: 'Total Volume',
          amount: stats.totalAmount,
          subtitle: 'Transaction Volume',
          icon: Icons.monetization_on,
          color: AppTheme.primaryColor,
          onTap: () => controller.applyFilter(status: 'all'),
        ),
        PaymentSummaryCard(
          title: 'Company Revenue',
          amount: stats.companyRevenue,
          subtitle: 'Earnings from fees',
          icon: Icons.account_balance,
          color: const Color(0xFF8B5CF6), // Purple for revenue
          // onTap: () => controller.applyFilter(type: 'delivery_fee'),
        ),
      ],
    );
  }

  Widget _buildTabletSummaryGrid(PaymentSummary stats) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 1.2,
      crossAxisSpacing: AppTheme.spacingLg,
      mainAxisSpacing: AppTheme.spacingLg,
      children: [
        PaymentSummaryCard(
          title: 'Total Pending',
          amount: stats.totalPending,
          subtitle: 'Awaiting clearance',
          icon: Icons.pending_actions,
          color: AppTheme.warningColor,
        ),
        PaymentSummaryCard(
          title: 'Collected (Holding)',
          amount: stats.collectedAmount,
          subtitle: '${stats.collectedCount} collected refunds',
          icon: Icons.account_balance_wallet,
          color: const Color(0xFFD97706),
        ),
        PaymentSummaryCard(
          title: 'Fully Cleared',
          amount: stats.clearedAmount,
          subtitle: 'Completed transactions',
          icon: Icons.check_circle,
          color: const Color(0xFF10B981),
        ),
        PaymentSummaryCard(
          title: 'Total Volume',
          amount: stats.totalAmount,
          subtitle: 'Total Volume',
          icon: Icons.monetization_on,
          color: AppTheme.primaryColor,
        ),
        PaymentSummaryCard(
          title: 'Company Revenue',
          amount: stats.companyRevenue,
          subtitle: 'Earnings',
          icon: Icons.account_balance,
          color: const Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  Widget _buildMobileSummaryGrid(PaymentSummary stats) {
    return Column(
      children: [
        PaymentSummaryCard(
          title: 'Total Pending',
          amount: stats.totalPending,
          subtitle: 'Awaiting clearance',
          icon: Icons.pending_actions,
          color: AppTheme.warningColor,
        ),
        const SizedBox(height: 12),
        PaymentSummaryCard(
          title: 'Collected (Holding)',
          amount: stats.collectedAmount,
          subtitle: '${stats.collectedCount} collected refunds',
          icon: Icons.account_balance_wallet,
          color: const Color(0xFFD97706),
        ),
        const SizedBox(height: 12),
        PaymentSummaryCard(
          title: 'Fully Cleared',
          amount: stats.clearedAmount,
          subtitle: 'Completed transactions',
          icon: Icons.check_circle,
          color: const Color(0xFF10B981),
        ),
        const SizedBox(height: 12),
        PaymentSummaryCard(
          title: 'Total Volume',
          amount: stats.totalAmount,
          subtitle: 'Total Volume',
          icon: Icons.monetization_on,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: 12),
        PaymentSummaryCard(
          title: 'Company Revenue',
          amount: stats.companyRevenue,
          subtitle: 'Earnings',
          icon: Icons.account_balance,
          color: const Color(0xFF8B5CF6),
        ),
      ],
    );
  }
}

/*
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTheme.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final Function(String) onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label:',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            dropdownColor: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(12),
            items:
                items.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.toUpperCase()),
                  );
                }).toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}
