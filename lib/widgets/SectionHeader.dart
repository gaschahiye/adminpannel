import 'package:flutter/material.dart';

import '../theme/theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final bool showDivider;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.headlineSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (action != null) action!,
          ],
        ),
        if (showDivider) ...[
          const SizedBox(height: 16),
          Divider(
            color: AppTheme.borderColor.withOpacity(0.5),
            thickness: 1,
            height: 1,
          ),
        ],
      ],
    );
  }
}
