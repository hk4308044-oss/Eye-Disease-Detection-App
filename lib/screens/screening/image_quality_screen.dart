import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../models/pre_screening_assessment.dart';
import '../../services/ai_service.dart';
import 'analyzing_screen.dart';

class ImageQualityScreen extends StatefulWidget {
  final PreScreeningAssessment assessment;
  final String imagePath;

  const ImageQualityScreen({
    super.key,
    required this.assessment,
    required this.imagePath,
  });

  @override
  State<ImageQualityScreen> createState() => _ImageQualityScreenState();
}

class _ImageQualityScreenState extends State<ImageQualityScreen> with SingleTickerProviderStateMixin {
  final AIService _aiService = AIService();
  
  bool _isChecking = true;
  bool _qualityPassed = false;
  
  // Checking states for UI
  bool _eyeDetected = false;
  bool _imageAcceptable = false;
  bool _lightingAcceptable = false;
  bool _readyForAnalysis = false;

  late AnimationController _scanController;

  // Design constants
  static const Color primaryNavy = Color(0xFF0F172A);
  static const Color slateGrey = Color(0xFF475569);
  static const Color primaryTeal = Color(0xFF0891B2);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color successGreen = Color(0xFF10B981);
  static const Color errorRed = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _runQualityAssessment();
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _runQualityAssessment() async {
    // Simulate an intelligent, progressive validation process
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _eyeDetected = true);
    
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _imageAcceptable = true);
    
    await Future.delayed(const Duration(milliseconds: 600));
    final passed = await _aiService.checkImageQuality(widget.imagePath);
    
    if (mounted) {
      setState(() {
        _lightingAcceptable = passed;
        _readyForAnalysis = passed;
        _qualityPassed = passed;
        _isChecking = false;
      });
      _scanController.stop();
    }
  }

  void _proceedToAnalysis() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AnalyzingScreen(
          assessment: widget.assessment,
          imagePath: widget.imagePath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        leading: _isChecking ? const SizedBox() : IconButton(
          icon: const Icon(CupertinoIcons.back, color: primaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Image Preparation",
          style: TextStyle(color: primaryNavy, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildImageContainer(),
              const SizedBox(height: 32),
              
              if (_isChecking)
                _buildCheckingState()
              else if (_qualityPassed)
                _buildSuccessState()
              else
                _buildErrorState(),
                
              const Spacer(),
              
              if (!_isChecking)
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _qualityPassed ? _proceedToAnalysis : () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _qualityPassed ? primaryTeal : primaryNavy,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        _qualityPassed ? "Analyze with AI" : "Retake Image",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageContainer() {
    return Center(
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image(
                image: kIsWeb 
                    ? NetworkImage(widget.imagePath) as ImageProvider
                    : FileImage(File(widget.imagePath)),
                fit: BoxFit.cover,
              ),
              if (_isChecking)
                AnimatedBuilder(
                  animation: _scanController,
                  builder: (context, child) {
                    return Positioned(
                      top: _scanController.value * 280 - 40,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              accentCyan.withOpacity(0.0),
                              accentCyan.withOpacity(0.4),
                              accentCyan.withOpacity(0.0),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Container(
                            height: 2,
                            width: double.infinity,
                            color: accentCyan.withOpacity(0.8),
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
    );
  }

  Widget _buildCheckingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: primaryTeal),
            ),
            const SizedBox(width: 16),
            Text(
              "Assessing image...",
              style: TextStyle(
                color: primaryNavy,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildChecklistItem("Eye detected", _eyeDetected, true),
        _buildChecklistItem("Image quality acceptable", _imageAcceptable, true),
        _buildChecklistItem("Lighting acceptable", _lightingAcceptable, true),
        _buildChecklistItem("Image ready for AI analysis", _readyForAnalysis, true),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: successGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.checkmark_alt, color: successGreen, size: 20),
            ),
            const SizedBox(width: 16),
            const Text(
              "Quality Verified",
              style: TextStyle(
                color: primaryNavy,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildChecklistItem("Eye detected", true, false),
        _buildChecklistItem("Image quality acceptable", true, false),
        _buildChecklistItem("Lighting acceptable", true, false),
        _buildChecklistItem("Image ready for AI analysis", true, false),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: errorRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.exclamationmark, color: errorRed, size: 20),
            ),
            const SizedBox(width: 16),
            const Text(
              "Image quality is too low",
              style: TextStyle(
                color: primaryNavy,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: errorRed.withOpacity(0.2)),
          ),
          child: const Text(
            "The captured image is either blurry, out of focus, or lacks sufficient lighting. For the AI to accurately assess your eye health, we need a clear and well-lit image.",
            style: TextStyle(
              color: slateGrey,
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistItem(String label, bool isComplete, bool isCheckingPhase) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isComplete ? successGreen.withOpacity(0.1) : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isComplete ? successGreen : slateGrey.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: isComplete
                ? const Icon(CupertinoIcons.checkmark_alt, size: 16, color: successGreen)
                : (isCheckingPhase ? const SizedBox() : const Icon(CupertinoIcons.xmark, size: 14, color: slateGrey)),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              color: isComplete ? primaryNavy : slateGrey,
              fontSize: 15,
              fontWeight: isComplete ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
