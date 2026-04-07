import 'package:flutter/material.dart';

import '../Models/payment_models.dart';
import '../theme/theme.dart';

class PaymentDataTable extends StatefulWidget {
  final List<PaymentTimelineEntry> payments;
  final Function(PaymentTimelineEntry, {String? referenceId, String? notes})
  onClearPayment;
  final bool isLoading;

  const PaymentDataTable({
    super.key,
    required this.payments,
    required this.onClearPayment,
    this.isLoading = false,
  });

  @override
  State<PaymentDataTable> createState() => _PaymentDataTableState();
}

class _PaymentDataTableState extends State<PaymentDataTable> {
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLg,
              vertical: AppTheme.spacingMd,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.03),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppTheme.borderRadiusMd),
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.borderColor.withOpacity(0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 8), // For the left accent space
                Expanded(
                  flex: isDesktop ? 2 : 1,
                  child: Text(
                    'DATE / ORDER',
                    style: AppTheme.labelMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary.withOpacity(0.4),
                      letterSpacing: 1.2,
                      fontSize: 10,
                    ),
                  ),
                ),
                Expanded(
                  flex: isDesktop ? 2 : 1,
                  child: Text(
                    'PERSON (NAME / TYPE)',
                    style: AppTheme.labelMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary.withOpacity(0.4),
                      letterSpacing: 1.2,
                      fontSize: 10,
                    ),
                  ),
                ),
                if (isDesktop)
                  Expanded(
                    child: Text(
                      'TYPE',
                      style: AppTheme.labelMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary.withOpacity(0.4),
                        letterSpacing: 1.2,
                        fontSize: 10,
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(
                    'AMOUNT',
                    style: AppTheme.labelMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary.withOpacity(0.4),
                      letterSpacing: 1.2,
                      fontSize: 10,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'STATUS',
                    style: AppTheme.labelMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary.withOpacity(0.4),
                      letterSpacing: 1.2,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 80),
              ],
            ),
          ),

          // Table Body
          widget.isLoading
              ? const _LoadingRow()
              : widget.payments.isEmpty
              ? const _EmptyRow()
              : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.payments.length,
                itemBuilder: (context, index) {
                  return _PaymentRow(
                    payment: widget.payments[index],
                    isDesktop: isDesktop,
                    onClear: (p) => _showClearDialog(context, p),
                  );
                },
              ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, PaymentTimelineEntry payment) {
    final refController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.cardBg,
            title: Text('Clear Payment', style: AppTheme.headlineSmall),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: refController,
                  decoration: const InputDecoration(
                    labelText: 'Reference ID',
                    hintText: 'Enter transaction reference',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Optional notes',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.onClearPayment(
                    payment,
                    referenceId: refController.text,
                    notes: notesController.text,
                  );
                  Navigator.pop(context);
                },
                child: const Text('Clear'),
              ),
            ],
          ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final PaymentTimelineEntry payment;
  final bool isDesktop;
  final Function(PaymentTimelineEntry) onClear;

  const _PaymentRow({
    required this.payment,
    required this.isDesktop,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    bool isHoveredLocal = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) => setState(() => isHoveredLocal = true),
          onExit: (_) => setState(() => isHoveredLocal = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLg,
              vertical: AppTheme.spacingMd,
            ),
            decoration: BoxDecoration(
              color:
                  isHoveredLocal
                      ? AppTheme.primaryColor.withOpacity(0.03)
                      : Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.borderColor.withOpacity(0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                // Left Accent Indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 4,
                  height: isHoveredLocal ? 24 : 0,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: isHoveredLocal ? 12 : 16),
                Expanded(
                  flex: isDesktop ? 2 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${payment.orderId}',
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${payment.date.day}/${payment.date.month}/${payment.date.year}',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: isDesktop ? 2 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.personName,
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (payment.personType.toLowerCase() == 'seller'
                                  ? AppTheme.primaryColor
                                  : AppTheme.secondaryColor)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          payment.personType.toUpperCase(),
                          style: AppTheme.bodySmall.copyWith(
                            color:
                                payment.personType.toLowerCase() == 'seller'
                                    ? AppTheme.primaryColor
                                    : AppTheme.secondaryColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isDesktop)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.type.displayTitle,
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (payment.cause != null &&
                            payment.cause!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            payment.cause!,
                            style: AppTheme.bodySmall.copyWith(
                              color:
                                  payment.liability == LiabilityType.refundable
                                      ? AppTheme.secondaryColor
                                      : AppTheme.textSecondary,
                              fontWeight:
                                  payment.liability == LiabilityType.refundable
                                      ? FontWeight.w700
                                      : FontWeight.normal,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                Expanded(
                  child: Text(
                    'Rs ${payment.amount.toInt()}',
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: payment.status.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: payment.status.color.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: payment.status.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            payment.displayStatus,
                            style: AppTheme.labelMedium.copyWith(
                              color: payment.status.color,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (payment.status == PaymentStatus.pending)
                        _CircleActionButton(
                          icon: Icons.check_rounded,
                          color: AppTheme.primaryColor,
                          onPressed: () => onClear(payment),
                          tooltip: 'Clear Payment',
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String tooltip;

  const _CircleActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(100),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}

class _LoadingRow extends StatelessWidget {
  const _LoadingRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(60),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor.withOpacity(0.2),
                    ),
                  ),
                  CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Fetching Ledger...',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary.withOpacity(0.5),
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  const _EmptyRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 48,
                color: AppTheme.textSecondary.withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Transactions Yet',
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary.withOpacity(0.6),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When payments are processed, they will appear here.',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
