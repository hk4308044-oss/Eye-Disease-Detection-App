import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable Background Blobs widget providing soft, translucent, non-intrusive
/// gradient shapes at corners & screen edges for a high-end medical-AI look.
class BackgroundBlobs extends StatelessWidget {
  final Widget child;
  final bool showTopLeft;
  final bool showTopRight;
  final bool showBottomLeft;
  final bool showBottomRight;

  const BackgroundBlobs({
    super.key,
    required this.child,
    this.showTopLeft = true,
    this.showTopRight = true,
    this.showBottomLeft = true,
    this.showBottomRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Blobs Layer
        Positioned.fill(
          child: IgnorePointer(
            child: Stack(
              children: [
                if (showTopRight)
                  Positioned(
                    top: -60,
                    right: -60,
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.primaryTeal.withValues(alpha: 0.12),
                            AppTheme.aiTeal.withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                if (showTopLeft)
                  Positioned(
                    top: 100,
                    left: -80,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.aiTeal.withValues(alpha: 0.08),
                            AppTheme.lightTeal.withValues(alpha: 0.04),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                if (showBottomLeft)
                  Positioned(
                    bottom: 120,
                    left: -70,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.primaryNavy.withValues(alpha: 0.04),
                            AppTheme.primaryTeal.withValues(alpha: 0.06),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                if (showBottomRight)
                  Positioned(
                    bottom: -50,
                    right: -50,
                    child: Container(
                      width: 230,
                      height: 230,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.aiTeal.withValues(alpha: 0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Screen Foreground Content
        child,
      ],
    );
  }
}
