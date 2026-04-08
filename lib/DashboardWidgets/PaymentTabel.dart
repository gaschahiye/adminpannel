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

    String dialogTitle = 'Clear Payment';
    String actionLabel = 'Clear';
    if (payment.type == PaymentType.refund || payment.type == PaymentType.partialRefund) {
      if (payment.status == PaymentStatus.pending) {
        dialogTitle = 'Collect from Seller';
        actionLabel = 'Collect';
      } else if (payment.status == PaymentStatus.collected) {
        dialogTitle = 'Refund to Buyer';
        actionLabel = 'Refund';
      }
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.cardBg,
            title: Text(dialogTitle, style: AppTheme.headlineSmall),
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
                child: Text(actionLabel),
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
    
    String displayPersonName = payment.personName;
    String displayPersonType = payment.personType;
    String displayPersonPhone = payment.personPhone;

    if (payment.type == PaymentType.refund || payment.type == PaymentType.partialRefund) {
      if (payment.status == PaymentStatus.pending) {
        if (payment.sellerName != null && payment.sellerName!.isNotEmpty) {
          displayPersonName = payment.sellerName!;
          displayPersonType = 'seller';
          if (payment.sellerPhone != null && payment.sellerPhone!.isNotEmpty) {
            displayPersonPhone = payment.sellerPhone!;
          }
        }
      } else if (payment.status == PaymentStatus.collected || payment.status == PaymentStatus.completed) {
        if (payment.buyerName != null && payment.buyerName!.isNotEmpty) {
          displayPersonName = payment.buyerName!;
          displayPersonType = 'buyer';
          if (payment.buyerPhone != null && payment.buyerPhone!.isNotEmpty) {
            displayPersonPhone = payment.buyerPhone!;
          }
        }
      }
    }

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) => setState(() => isHoveredLocal = true),
          onExit: (_) => setState(() => isHoveredLocal = false),
          child: GestureDetector(
            onTap: () => _showPaymentDetailsDialog(context, payment),
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
                        displayPersonName,
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: (displayPersonType.toLowerCase() == 'seller'
                                      ? AppTheme.primaryColor
                                      : AppTheme.secondaryColor)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              displayPersonType.toUpperCase(),
                              style: AppTheme.bodySmall.copyWith(
                                color:
                                    displayPersonType.toLowerCase() == 'seller'
                                        ? AppTheme.primaryColor
                                        : AppTheme.secondaryColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          if (displayPersonPhone.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              displayPersonPhone,
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
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
                  width: 140, // Increased width for text buttons
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if ((payment.type == PaymentType.refund || payment.type == PaymentType.partialRefund) && payment.status == PaymentStatus.pending)
                        _ActionButton(
                          icon: Icons.account_balance_wallet,
                          label: 'Collect',
                          color: const Color(0xFFF59E0B),
                          onPressed: () => onClear(payment),
                        )
                      else if ((payment.type == PaymentType.refund || payment.type == PaymentType.partialRefund) && payment.status == PaymentStatus.collected)
                        _ActionButton(
                          icon: Icons.payment,
                          label: 'Refund',
                          color: const Color(0xFF10B981),
                          onPressed: () => onClear(payment),
                        )
                      else if (payment.status == PaymentStatus.pending)
                        _ActionButton(
                          icon: Icons.check_rounded,
                          label: 'Clear',
                          color: AppTheme.primaryColor,
                          onPressed: () => onClear(payment),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
    );
  }
  
  void _showPaymentDetailsDialog(BuildContext context, PaymentTimelineEntry payment) {
    showDialog(
      context: context,
      builder: (context) {
        final isRefund = payment.type == PaymentType.refund || payment.type == PaymentType.partialRefund;
        return Dialog(
          backgroundColor: AppTheme.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Payment Details', style: AppTheme.headlineMedium),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Summary Block
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.darkBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order #${payment.orderId}', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                          const SizedBox(height: 4),
                          Text(payment.type.displayTitle, style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text('Rs ${payment.amount.toInt()}', style: AppTheme.headlineMedium.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Stepper
                Text('Status Progress', style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (isRefund) ...[
                  _buildRefundStepper(payment.status),
                ] else ...[
                  _buildStandardStepper(payment.status),
                ],

                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.darkBg,
                      foregroundColor: AppTheme.textPrimary,
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStandardStepper(PaymentStatus status) {
    bool isCompleted = status == PaymentStatus.completed;
    return Column(
      children: [
        _StepperStep(title: 'Pending / Requested', isActive: true, isCompleted: isCompleted),
        _StepperLine(isActive: isCompleted),
        _StepperStep(title: 'Completed / Cleared', isActive: isCompleted, isCompleted: isCompleted),
      ],
    );
  }

  Widget _buildRefundStepper(PaymentStatus status) {
    bool isCollected = status == PaymentStatus.collected || status == PaymentStatus.completed;
    bool isCompleted = status == PaymentStatus.completed;
    return Column(
      children: [
        _StepperStep(title: 'Refund Requested (Pending)', isActive: true, isCompleted: isCollected),
        _StepperLine(isActive: isCollected),
        _StepperStep(title: 'Collected from Seller', isActive: isCollected, isCompleted: isCompleted),
        _StepperLine(isActive: isCompleted),
        _StepperStep(title: 'Paid to Buyer (Completed)', isActive: isCompleted, isCompleted: isCompleted),
      ],
    );
  }
}

class _StepperStep extends StatelessWidget {
  final String title;
  final bool isActive;
  final bool isCompleted;

  const _StepperStep({required this.title, required this.isActive, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    Color color = isCompleted ? AppTheme.primaryColor : (isActive ? const Color(0xFFF59E0B) : AppTheme.textSecondary.withOpacity(0.3));
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? color : Colors.transparent,
            border: Border.all(color: color, width: 2),
          ),
          child: isCompleted ? const Icon(Icons.check, size: 16, color: Colors.white) : (isActive ? Icon(Icons.circle, size: 10, color: color) : null),
        ),
        const SizedBox(width: 12),
        Text(title, style: AppTheme.bodyMedium.copyWith(color: isActive ? AppTheme.textPrimary : AppTheme.textSecondary, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}

class _StepperLine extends StatelessWidget {
  final bool isActive;

  const _StepperLine({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 11, top: 4, bottom: 4),
      width: 2,
      height: 24,
      color: isActive ? AppTheme.primaryColor : AppTheme.textSecondary.withOpacity(0.3),
      alignment: Alignment.centerLeft,
    );
  }
}

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
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTheme.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ],
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
