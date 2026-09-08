import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/pre_screening_assessment.dart';
import '../../services/ai_service.dart';
import '../../services/database_service.dart';
import 'result_screen.dart';

class AnalyzingScreen extends StatefulWidget {
  final PreScreeningAssessment assessment;
  final String imagePath;

  const AnalyzingScreen({
    super.key,
    required this.assessment,
    required this.imagePath,
  });

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen> with SingleTickerProviderStateMixin {
  final AIService _aiService = AIService();
  final DatabaseService _dbService = DatabaseService();
  late AnimationController _pulseController;
  
  bool _hasError = false;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _startAnalysis();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startAnalysis() async {
    setState(() {
      _hasError = false;
      _pulseController.repeat(reverse: true);
    });
    
    try {
      final record = await _aiService.analyzeImage(
        imagePath: widget.imagePath,
        assessment: widget.assessment,
      );
      
      // Save to database
      await _dbService.saveScreening(record);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(record: record),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString()
            .replaceAll("SocketException: ", "")
            .replaceAll("Exception: ", "")
            .replaceAll("ModelNotLoadedException: ", "");
          _pulseController.stop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: _hasError ? _buildErrorView(theme) : _buildAnalyzingView(theme, colorScheme, textTheme),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.cloud_off_outlined, size: 80, color: Colors.orange),
        const SizedBox(height: 24),
        Text("Connection Error", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text(
          _errorMessage,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _startAnalysis,
            icon: const Icon(Icons.refresh),
            label: const Text("Retry Analysis"),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Go Back"),
        )
      ],
    );
  }

  Widget _buildAnalyzingView(ThemeData theme, ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            FadeTransition(
              opacity: _pulseController,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withValues(alpha: 0.15),
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.file(
                File(widget.imagePath),
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              child: SizedBox(
                width: 170,
                height: 170,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),
        Text(
          "AI Analysis in Progress",
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Our model is currently analyzing your image and health context.",
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
