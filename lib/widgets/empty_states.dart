import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final bool isLoading;

  const PremiumStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const CircularProgressIndicator(color: AppTheme.primaryBlue)
            else
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.softBlue,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.subtleShadow,
                ),
                child: Icon(icon, size: 48, color: AppTheme.primaryBlue),
              ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class PremiumLoading extends StatelessWidget {
  final String message;
  const PremiumLoading({super.key, this.message = "Loading data..."});

  @override
  Widget build(BuildContext context) {
    return PremiumStateWidget(
      icon: Icons.hourglass_empty,
      title: "Please wait",
      message: message,
      isLoading: true,
    );
  }
}

class PremiumEmpty extends StatelessWidget {
  final String title;
  final String message;
  const PremiumEmpty({
    super.key,
    this.title = "No Data Found",
    this.message = "There is nothing to display here yet.",
  });

  @override
  Widget build(BuildContext context) {
    return PremiumStateWidget(
      icon: Icons.inbox_outlined,
      title: title,
      message: message,
    );
  }
}
