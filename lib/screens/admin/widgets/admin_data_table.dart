import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Reusable table / list card shell for admin management screens
class AdminDataTableCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String searchHint;
  final ValueChanged<String>? onSearchChanged;
  final List<Widget>? headerActions;
  final Widget child;

  const AdminDataTableCard({
    super.key,
    required this.title,
    this.subtitle,
    this.searchHint = 'Search...',
    this.onSearchChanged,
    this.headerActions,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryNavy.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryNavy,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textLightSecondary,
                            ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (headerActions != null) Row(children: headerActions!),
              ],
            ),
          ),
          if (onSearchChanged != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: searchHint,
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textLightSecondary, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderLight),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          const Divider(height: 1),
          child,
        ],
      ),
    );
  }
}
