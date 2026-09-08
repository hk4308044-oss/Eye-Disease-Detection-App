import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:async';
import '../../theme/app_theme.dart';
import '../../services/eye_screening_service.dart';
import 'screening_result_screen.dart';
import 'ai_analysis_processing_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AiImagePreparationScreen extends StatefulWidget {
  final String imagePath;
  final String category;
  
  const AiImagePreparationScreen({
    super.key,
    required this.imagePath,
    required this.category,
  });

  @override
  State<AiImagePreparationScreen> createState() => _AiImagePreparationScreenState();
}

class _AiImagePreparationScreenState extends State<AiImagePreparationScreen> with TickerProviderStateMixin {
  int _completedChecks = 0;
  bool _isProcessing = true;
  bool _isValid = true;
  
  late AnimationController _pulseController;
  late AnimationController _scannerController;

  final List<String> _checkItems = [
    "Eye detected",
    "Image quality acceptable",
    "Lighting acceptable",
    "Image ready for AI analysis",
  ];

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    _runQualityChecks();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _runQualityChecks() async {
    // Simulate preprocessing and quality checks
    for (int i = 0; i < _checkItems.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() {
          _completedChecks = i + 1;
        });
      }
    }
    
    // Simulate final validation logic (always valid for demo, 
    // but in reality this would depend on actual image quality metrics)
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _isValid = true; // Set to false to see the error state
      });
    }
  }

  Future<void> _startAnalysis() async {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => AiAnalysisProcessingScreen(
            imagePath: widget.imagePath,
            category: widget.category,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: Colors.black, // Premium dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Image Preparation",
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background ambient gradient
          Positioned(
            top: -100,
            right: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.secondary.withOpacity(0.15),
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Prominent Image Display
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Center(
                    child: Hero(
                      tag: 'captured_image',
                      child: Container(
                        height: 280,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                              offset: const Offset(0, 10),
                            ),
                            if (_isProcessing)
                              BoxShadow(
                                color: colorScheme.secondary.withOpacity(0.3 * _pulseController.value),
                                blurRadius: 30,
                                spreadRadius: 5,
                              )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
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
                              
                              // Scanner Animation Overlay
                              if (_isProcessing)
                                AnimatedBuilder(
                                  animation: _scannerController,
                                  builder: (context, child) {
                                    return Positioned(
                                      top: 280 * (_scannerController.value * 2 - 0.5),
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 100,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              colorScheme.secondary.withOpacity(0.0),
                                              colorScheme.secondary.withOpacity(0.2),
                                              colorScheme.secondary.withOpacity(0.0),
                                            ],
                                          ),
                                        ),
                                        child: Center(
                                          child: Container(
                                            height: 2,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: colorScheme.secondary,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: colorScheme.secondary.withOpacity(0.8),
                                                  blurRadius: 8,
                                                  spreadRadius: 2,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Assessment Panel
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      border: Border(
                        top: BorderSide(color: Colors.white.withOpacity(0.05)),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Quality Assessment",
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Checkmarks
                        Expanded(
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _checkItems.length,
                            itemBuilder: (context, index) {
                              final isCompleted = index < _completedChecks;
                              final isCurrent = index == _completedChecks;
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 400),
                                  opacity: isCompleted || isCurrent ? 1.0 : 0.3,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isCompleted 
                                              ? AppTheme.statusGreen.withOpacity(0.2) 
                                              : (isCurrent ? colorScheme.secondary.withOpacity(0.2) : Colors.white.withOpacity(0.05)),
                                          border: Border.all(
                                            color: isCompleted 
                                                ? AppTheme.statusGreen 
                                                : (isCurrent ? colorScheme.secondary : Colors.white.withOpacity(0.1)),
                                          ),
                                        ),
                                        child: isCompleted 
                                            ? const Icon(Icons.check, size: 16, color: AppTheme.statusGreen)
                                            : (isCurrent 
                                                ? Padding(
                                                    padding: const EdgeInsets.all(6.0),
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: colorScheme.secondary,
                                                    ),
                                                  )
                                                : null),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        _checkItems[index],
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          color: isCompleted || isCurrent ? Colors.white : Colors.white.withOpacity(0.5),
                                          fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        
                        // Status & CTA Actions
                        if (!_isProcessing)
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 500),
                            opacity: 1.0,
                            child: _isValid ? _buildSuccessActions(theme) : _buildErrorActions(theme),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _buildSuccessActions(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.statusGreen, size: 20),
            const SizedBox(width: 12),
            Text(
              "System is ready",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.statusGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _startAnalysis,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              "Analyze with AI",
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorActions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.error_outline, color: AppTheme.statusRed, size: 20),
            const SizedBox(width: 12),
            Text(
              "Image quality is too low",
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppTheme.statusRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Please ensure the eye is clearly visible, well-lit, and centered in the frame. Avoid reflections and blur.",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withOpacity(0.7),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withOpacity(0.3)),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              "Retake Image",
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
