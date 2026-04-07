import 'package:flutter/material.dart';

import '../theme/theme.dart';

class PaymentSummaryCard extends StatefulWidget {
  final String title;
  final double amount;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double? changePercent;
  final VoidCallback? onTap;
  final bool isCompact;
  final bool isCurrency;

  const PaymentSummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.changePercent,
    this.onTap,
    this.isCompact = false,
    this.isCurrency = true,
  });

  @override
  State<PaymentSummaryCard> createState() => _PaymentSummaryCardState();
}

class _PaymentSummaryCardState extends State<PaymentSummaryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:
          widget.onTap != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuint,
          transform:
              Matrix4.identity()..translate(0.0, _isHovered ? -8.0 : 0.0),
          decoration: BoxDecoration(
            color: AppTheme.cardBg.withOpacity(0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color:
                  _isHovered
                      ? widget.color.withOpacity(0.4)
                      : widget.color.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    _isHovered
                        ? widget.color.withOpacity(0.15)
                        : widget.color.withOpacity(0.05),
                blurRadius: _isHovered ? 30 : 20,
                offset: Offset(0, _isHovered ? 15 : 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Ultra-Elite Mesh Gradient Layer
                Positioned(
                  right: -30,
                  top: -30,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          widget.color.withOpacity(_isHovered ? 0.2 : 0.1),
                          widget.color.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: widget.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              widget.icon,
                              color: widget.color,
                              size: 20,
                            ),
                          ),
                          if (widget.changePercent != null)
                            _PulsingTrendBadge(
                              changePercent: widget.changePercent!,
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.title.toUpperCase(),
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w900,
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          if (widget.isCurrency)
                            Text(
                              'RS',
                              style: AppTheme.bodyLarge.copyWith(
                                color: AppTheme.textPrimary.withOpacity(0.3),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                          if (widget.isCurrency) const SizedBox(width: 4),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.isCurrency
                                    ? _formatAmount(widget.amount)
                                    : widget.amount.toInt().toString(),
                                style: AppTheme.headlineLarge.copyWith(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textPrimary,
                                  height: 1,
                                  letterSpacing: -1.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Elite Minimal Trend Line
                      Container(
                        height: 3,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.65,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.color,
                                  widget.color.withOpacity(0.3),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.subtitle,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary.withOpacity(0.4),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000)
      return '${(amount / 10000000).toStringAsFixed(1)} Cr';
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)} L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)} K';
    return amount.toStringAsFixed(0);
  }
}

class _PulsingTrendBadge extends StatefulWidget {
  final double changePercent;
  const _PulsingTrendBadge({required this.changePercent});

  @override
  State<_PulsingTrendBadge> createState() => _PulsingTrendBadgeState();
}

class _PulsingTrendBadgeState extends State<_PulsingTrendBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.changePercent >= 0
            ? const Color(0xFF10B981)
            : const Color(0xFFEF4444);
    return FadeTransition(
      opacity: Tween<double>(begin: 0.7, end: 1.0).animate(_controller),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(
              widget.changePercent >= 0
                  ? Icons.trending_up
                  : Icons.trending_down,
              size: 12,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              '${widget.changePercent >= 0 ? '+' : ''}${widget.changePercent.toStringAsFixed(1)}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const PaymentStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSm),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSm),
            ),
            child: Center(child: Icon(icon, size: 18, color: color)),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTheme.headlineSmall.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
