import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../models/eye_screening_result.dart';
import '../../services/firebase_service.dart';
import '../referral/referral_map_screen.dart';
import '../reports/report_preview_screen.dart';
import 'ai_health_analytics_screen.dart';
import '../specialist/find_specialist_screen.dart';
import '../../theme/app_theme.dart';

class ScreeningResultScreen extends StatefulWidget {
  final EyeScreeningResult result;
  final String? imagePath;
  
  const ScreeningResultScreen({
    super.key, 
    required this.result,
    this.imagePath,
  });

  @override
  State<ScreeningResultScreen> createState() => _ScreeningResultScreenState();
}

class _ScreeningResultScreenState extends State<ScreeningResultScreen> with SingleTickerProviderStateMixin {
  bool _isSaving = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color _getSeverityColor() {
    switch (widget.result.riskLevel) {
      case RiskLevel.low:
        return const Color(0xFF16A34A); // Mild / Normal (Green)
      case RiskLevel.attention:
        return const Color(0xFFD97706); // Moderate (Orange)
      case RiskLevel.high:
        return const Color(0xFFDC2626); // Severe (Red)
    }
  }

  String _getSeverityLabel() {
    switch (widget.result.riskLevel) {
      case RiskLevel.low:
        return "Mild / Normal";
      case RiskLevel.attention:
        return "Moderate Risk";
      case RiskLevel.high:
        return "Severe Risk";
    }
  }

  IconData _getSeverityIcon() {
    switch (widget.result.riskLevel) {
      case RiskLevel.low:
        return Icons.check_circle_outline;
      case RiskLevel.attention:
        return Icons.warning_amber_rounded;
      case RiskLevel.high:
        return Icons.error_outline_rounded;
    }
  }

  Future<void> _saveResult() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final service = FirebaseService();
      await service.saveScreeningResult(widget.result);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Result saved successfully to history.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save result: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _generatePdf() {
    // Placeholder for PDF generation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating PDF Report...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getSeverityColor();

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text(
          "Screening Result",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryNavy,
          ),
        ),
        backgroundColor: AppTheme.bgLight,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.primaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnim.value,
            child: Transform.translate(
              offset: Offset(0, _slideAnim.value),
              child: child,
            ),
          );
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Result Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppTheme.premiumShadowLight,
                  border: Border.all(color: color.withOpacity(0.2), width: 2),
                ),
                child: Column(
                  children: [
                    // Image and Top Summary
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Eye Image (Rounded)
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppTheme.bgSecondary,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: AppTheme.subtleShadowLight,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: widget.imagePath != null
                                  ? (kIsWeb 
                                      ? Image.network(widget.imagePath!, fit: BoxFit.cover)
                                      : Image.file(File(widget.imagePath!), fit: BoxFit.cover))
                                  : const Icon(CupertinoIcons.eye, size: 40, color: AppTheme.secondaryNavy),
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Condition & Severity
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "AI screening indicates...",
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: AppTheme.textLightSecondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.result.observation, // e.g. "Diabetic Retinopathy"
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryNavy,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Severity Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: color.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(_getSeverityIcon(), color: color, size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        _getSeverityLabel(),
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          color: color,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Divider(height: 1, color: AppTheme.borderLight),
                    
                    // Confidence Score
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "AI Confidence Score",
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: AppTheme.textLightSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Based on visual pattern matching",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textLightDisabled,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                widget.result.confidence.toStringAsFixed(1),
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: AppTheme.primaryNavy,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                "%",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: AppTheme.textLightSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Educational & Next Steps Sections
              _buildSectionTitle(theme, "What this means"),
              const SizedBox(height: 12),
              _buildInfoCard(
                child: Text(
                  widget.result.explanation.isNotEmpty 
                      ? widget.result.explanation 
                      : "The AI has analyzed the retinal patterns and identified markers consistent with ${widget.result.observation}. This is a preliminary assessment based on visual indicators.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textLightPrimary,
                    height: 1.6,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),

              _buildSectionTitle(theme, "Recommended next steps"),
              const SizedBox(height: 12),
              _buildInfoCard(
                child: Column(
                  children: [
                    _buildStepRow(1, widget.result.riskLevel == RiskLevel.low ? "Continue regular eye check-ups as scheduled." : "Schedule an appointment with an ophthalmologist for a comprehensive eye exam."),
                    const SizedBox(height: 12),
                    _buildStepRow(2, "Keep a record of this screening to show your doctor."),
                    const SizedBox(height: 12),
                    _buildStepRow(3, "Monitor for any changes in your vision, such as blurriness or spots."),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _buildSectionTitle(theme, "When to consult an eye specialist"),
              const SizedBox(height: 12),
              _buildInfoCard(
                child: Column(
                  children: [
                    _buildBulletPoint("If you experience sudden vision loss or changes."),
                    const SizedBox(height: 8),
                    _buildBulletPoint("If you have pre-existing conditions like diabetes."),
                    const SizedBox(height: 8),
                    _buildBulletPoint("If you notice increased floaters, flashes of light, or eye pain."),
                    if (widget.result.riskLevel != RiskLevel.low) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ReferralMapScreen()),
                            );
                          },
                          icon: const Icon(Icons.location_on_outlined, size: 18),
                          label: const Text("Find Specialists Nearby"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryTeal,
                            side: const BorderSide(color: AppTheme.primaryTeal),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Find a Specialist CTA — integrated from AI result
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.lightTeal,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.aiTeal.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.medical_services_outlined, color: AppTheme.primaryTeal, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Find a Specialist Near You',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Want professional confirmation? Find an eye specialist near you.',
                      style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textLightSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FindSpecialistScreen(
                                screeningCategory: widget.result.observation,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.search_rounded, size: 18),
                        label: const Text('Find Specialist'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AiHealthAnalyticsScreen(result: widget.result),
                      ),
                    );
                  },
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text("View Detailed Analysis", style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReportPreviewScreen(
                                result: widget.result,
                                imagePath: widget.imagePath,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
                        label: const Text("Generate PDF Report", style: TextStyle(fontSize: 14)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryNavy,
                          side: const BorderSide(color: AppTheme.borderLight, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: _isSaving ? null : _saveResult,
                        icon: _isSaving 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.history_rounded, size: 20),
                        label: Text(_isSaving ? "Saving..." : "Save to History", style: const TextStyle(fontSize: 14)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryNavy,
                          side: const BorderSide(color: AppTheme.borderLight, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Medical Disclaimer Bottom
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.bgSecondary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.medical_information_outlined, color: AppTheme.textLightDisabled, size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "This result requires professional confirmation. The AI screening is for preliminary assessment only and does not replace a definitive medical diagnosis by a qualified healthcare provider.",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textLightSecondary,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryNavy,
      ),
    );
  }

  Widget _buildInfoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.subtleShadowLight,
        border: Border.all(color: AppTheme.borderLight, width: 0.5),
      ),
      child: child,
    );
  }

  Widget _buildStepRow(int step, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.bgSecondary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              "$step",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryNavy,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textLightPrimary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6.0, right: 12.0),
          child: Icon(Icons.circle, size: 6, color: AppTheme.primaryTeal),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textLightPrimary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
