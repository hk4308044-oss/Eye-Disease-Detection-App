import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'dart:ui';
import '../../theme/app_theme.dart';
import '../../services/eye_screening_service.dart';
import '../../models/eye_screening_result.dart';
import 'screening_result_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AiAnalysisProcessingScreen extends StatefulWidget {
  final String imagePath;
  final String category;

  const AiAnalysisProcessingScreen({
    super.key,
    required this.imagePath,
    required this.category,
  });

  @override
  State<AiAnalysisProcessingScreen> createState() => _AiAnalysisProcessingScreenState();
}

class _AiAnalysisProcessingScreenState extends State<AiAnalysisProcessingScreen> with TickerProviderStateMixin {
  int _currentStageIndex = 0;
  
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late AnimationController _scanController;

  final List<String> _stages = [
    "Image Validation",
    "Image Enhancement",
    "AI Pattern Analysis",
    "Disease Classification",
    "Risk Assessment"
  ];

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _progressController.addListener(() {
      final newStageIndex = (_progressController.value * _stages.length).floor().clamp(0, _stages.length - 1);
      if (newStageIndex != _currentStageIndex) {
        setState(() {
          _currentStageIndex = newStageIndex;
        });
      }
    });

    _startAnalysis();
  }

  Future<void> _startAnalysis() async {
    // Start the visual progress
    _progressController.forward();
    
    // Call the actual AI service
    final service = EyeScreeningService();
    EyeScreeningResult? result;
    
    try {
      result = await service.analyzeEyeImage(
        imagePath: widget.imagePath,
        category: widget.category,
      );
    } catch (e) {
      // Handle error gracefully if needed
      debugPrint("Error during analysis: $e");
    }

    // Ensure the animation completes before transitioning
    if (_progressController.isAnimating) {
      await _progressController.forward();
    }
    
    // Brief pause at 100% before transition
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted && result != null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => ScreeningResultScreen(
            result: result!,
            imagePath: widget.imagePath,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } else if (mounted) {
       // Pop back if error occurred and result is null
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Analysis failed. Please try again.'))
       );
       Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background ambient gradient
          Positioned(
            top: -150,
            left: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.aiTeal.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.aiTeal.withValues(alpha: 0.05),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Header
                Text(
                  "AI Processing",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Analyzing visual patterns",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                
                const SizedBox(height: 48),

                // Premium Image Preview with scanning effect
                Center(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.aiTeal.withValues(alpha: 0.3 + 0.3 * _pulseController.value),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.aiTeal.withValues(alpha: 0.15 * _pulseController.value),
                              blurRadius: 30,
                              spreadRadius: 10,
                            )
                          ],
                        ),
                        child: child,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipOval(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            kIsWeb 
                                ? Image.network(
                                    widget.imagePath,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(widget.imagePath),
                                    fit: BoxFit.cover,
                                  ),
                            ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                AppTheme.aiTeal.withValues(alpha: 0.2),
                                BlendMode.overlay,
                              ),
                              child: Container(color: Colors.transparent),
                            ),
                            // Scanning line animation
                            AnimatedBuilder(
                              animation: _scanController,
                              builder: (context, child) {
                                return Positioned(
                                  top: 240 * _scanController.value - 20,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          AppTheme.aiTeal.withValues(alpha: 0.0),
                                          AppTheme.aiTeal.withValues(alpha: 0.4),
                                          AppTheme.aiTeal.withValues(alpha: 0.0),
                                        ],
                                      ),
                                    ),
                                    child: Center(
                                      child: Container(
                                        height: 2,
                                        width: double.infinity,
                                        color: AppTheme.aiTeal,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Tech overlay grid
                            CustomPaint(
                              painter: GridOverlayPainter(color: AppTheme.aiTeal.withValues(alpha: 0.15)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 56),

                // Stages Progress List
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(_stages.length, (index) {
                        final isCompleted = index < _currentStageIndex;
                        final isCurrent = index == _currentStageIndex;
                        final isWaiting = index > _currentStageIndex;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Row(
                            children: [
                              // Status Icon
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: isCompleted
                                    ? const Icon(Icons.check_circle, color: AppTheme.aiTeal, size: 24)
                                    : isCurrent
                                        ? AnimatedBuilder(
                                            animation: _pulseController,
                                            builder: (context, child) {
                                              return Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: AppTheme.aiTeal.withValues(alpha: 0.5 + 0.5 * _pulseController.value),
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: AppTheme.aiTeal.withValues(alpha: 0.5 + 0.5 * _pulseController.value),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          )
                                        : Icon(Icons.circle_outlined, color: Colors.white.withValues(alpha: 0.2), size: 24),
                              ),
                              const SizedBox(width: 16),
                              
                              // Stage Name
                              Expanded(
                                child: Text(
                                  _stages[index],
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: isCompleted || isCurrent ? Colors.white : Colors.white.withValues(alpha: 0.4),
                                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),

                              // Status Text
                              Text(
                                isCompleted
                                    ? "✓"
                                    : isCurrent
                                        ? "Processing"
                                        : "Waiting",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isCompleted
                                      ? AppTheme.aiTeal
                                      : isCurrent
                                          ? AppTheme.aiTeal.withValues(alpha: 0.8)
                                          : Colors.white.withValues(alpha: 0.3),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                // Medical Disclaimer
                Container(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Colors.white.withValues(alpha: 0.4), size: 16),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "This screening provides preliminary health information and does not replace professional medical diagnosis.",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.4),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 28), // balance the icon
                    ],
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

class GridOverlayPainter extends CustomPainter {
  final Color color;

  GridOverlayPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double step = 20.0;

    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
