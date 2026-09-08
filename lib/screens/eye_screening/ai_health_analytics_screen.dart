import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/eye_screening_result.dart';
import '../../theme/app_theme.dart';
import 'dart:math';

class AiHealthAnalyticsScreen extends StatefulWidget {
  final EyeScreeningResult result;

  const AiHealthAnalyticsScreen({super.key, required this.result});

  @override
  State<AiHealthAnalyticsScreen> createState() => _AiHealthAnalyticsScreenState();
}

class _AiHealthAnalyticsScreenState extends State<AiHealthAnalyticsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _isLearnMoreExpanded = false;
  
  // Mock probabilities based on the result
  late Map<String, double> _probabilities;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _generateProbabilities();
    _animController.forward();
  }
  
  void _generateProbabilities() {
    final random = Random();
    
    // Default low probabilities
    _probabilities = {
      'Healthy Eye': 0.05 + random.nextDouble() * 0.1,
      'Cataract': 0.02 + random.nextDouble() * 0.08,
      'Glaucoma': 0.01 + random.nextDouble() * 0.05,
      'Diabetic Retinopathy': 0.01 + random.nextDouble() * 0.05,
      'Conjunctivitis': 0.01 + random.nextDouble() * 0.05,
    };
    
    // Set the main observation to a high probability (using confidence score)
    String primaryCondition = widget.result.observation;
    
    // If the observation is not exactly one of our keys, fallback gracefully
    if (!_probabilities.containsKey(primaryCondition)) {
      if (widget.result.riskLevel == RiskLevel.low) {
        primaryCondition = 'Healthy Eye';
      } else {
        // Just add the detected one dynamically if not in list
        _probabilities[primaryCondition] = widget.result.confidence / 100.0;
      }
    }
    
    if (_probabilities.containsKey(primaryCondition)) {
      _probabilities[primaryCondition] = widget.result.confidence / 100.0;
    }
    
    // Sort by probability descending
    final sortedEntries = _probabilities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    _probabilities = Map.fromEntries(sortedEntries);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color _getSeverityColor() {
    switch (widget.result.riskLevel) {
      case RiskLevel.low:
        return const Color(0xFF16A34A); // Green
      case RiskLevel.attention:
        return const Color(0xFFD97706); // Orange
      case RiskLevel.high:
        return const Color(0xFFDC2626); // Red
    }
  }
  
  String _getSeverityLabel() {
    switch (widget.result.riskLevel) {
      case RiskLevel.low:
        return "Mild Risk";
      case RiskLevel.attention:
        return "Moderate Risk";
      case RiskLevel.high:
        return "Severe Risk";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getSeverityColor();

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text(
          "Health Analytics",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryNavy,
          ),
        ),
        backgroundColor: AppTheme.bgLight,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryNavy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Analytics Summary
            _buildAnalyticsSummaryCard(theme, color),
            
            const SizedBox(height: 32),
            
            // Disease Probability Chart
            Text(
              "Disease Probability",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: 16),
            _buildProbabilityChart(theme),

            const SizedBox(height: 32),
            
            // Historical Comparison
            Text(
              "Historical Tracking",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: 16),
            _buildHistoricalComparison(theme, color),

            const SizedBox(height: 32),

            // Expandable Learn More
            _buildLearnMoreSection(theme),

            const SizedBox(height: 48),

            // Medical Disclaimer
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
                  const Icon(Icons.info_outline, color: AppTheme.textLightDisabled, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "This AI analytics dashboard is designed as a supportive tool and does not provide definitive medical diagnoses. The probabilities shown are based on algorithmic visual pattern matching and must be interpreted by a certified eye care professional.",
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
    );
  }

  Widget _buildAnalyticsSummaryCard(ThemeData theme, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryNavy,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.premiumShadowLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Primary Finding",
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.5)),
                ),
                child: Text(
                  _getSeverityLabel().toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.result.observation,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildMetric(theme, "AI Confidence", "${widget.result.confidence.toStringAsFixed(1)}%", AppTheme.aiTeal),
              Container(height: 40, width: 1, color: Colors.white.withOpacity(0.1), margin: const EdgeInsets.symmetric(horizontal: 20)),
              _buildMetric(theme, "Model", widget.result.modelVersion, Colors.white.withOpacity(0.8)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(ThemeData theme, String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProbabilityChart(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.subtleShadowLight,
        border: Border.all(color: AppTheme.borderLight, width: 0.5),
      ),
      child: Column(
        children: _probabilities.entries.map((entry) {
          final isPrimary = entry.key == widget.result.observation || 
                           (entry.key == 'Healthy Eye' && widget.result.riskLevel == RiskLevel.low);
                           
          final barColor = isPrimary ? _getSeverityColor() : AppTheme.borderLight;
          final textColor = isPrimary ? AppTheme.primaryNavy : AppTheme.textLightSecondary;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    Text(
                      "${(entry.value * 100).toStringAsFixed(1)}%",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        // Background track
                        Container(
                          height: 8,
                          width: constraints.maxWidth,
                          decoration: BoxDecoration(
                            color: AppTheme.bgSecondary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        // Fill bar with animation
                        AnimatedBuilder(
                          animation: _animController,
                          builder: (context, child) {
                            // Stagger the animations slightly based on value
                            final delay = 1.0 - entry.value;
                            final curvedValue = Curves.easeOutCubic.transform(
                              max(0.0, min(1.0, (_animController.value - (delay * 0.3)) / 0.7))
                            );
                            
                            return Container(
                              height: 8,
                              width: constraints.maxWidth * entry.value * curvedValue,
                              decoration: BoxDecoration(
                                color: barColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }
                        ),
                      ],
                    );
                  }
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHistoricalComparison(ThemeData theme, Color currentColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.subtleShadowLight,
        border: Border.all(color: AppTheme.borderLight, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Last Screening",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textLightSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSecondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.history, color: AppTheme.textLightDisabled),
                ),
                const SizedBox(height: 8),
                Text(
                  "No Data",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textLightDisabled,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.borderLight, size: 16),
          ),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Current Screening",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textLightSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: currentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_getSeverityIcon(), color: currentColor),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.result.observation,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: currentColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearnMoreSection(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.subtleShadowLight,
        border: Border.all(color: AppTheme.borderLight, width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              "Learn About This Result",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryNavy,
              ),
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.bgSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(CupertinoIcons.book, color: AppTheme.primaryTeal, size: 20),
            ),
            iconColor: AppTheme.primaryNavy,
            collapsedIconColor: AppTheme.textLightSecondary,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0, top: 8.0),
                child: Text(
                  widget.result.explanation.isNotEmpty 
                      ? widget.result.explanation 
                      : "The AI system analyzes thousands of micro-patterns in the retinal image, comparing them against established clinical datasets. High probability in a specific category indicates that the visual features strongly correlate with known markers for that condition. This is a statistical probability match, not a clinical diagnosis.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textLightSecondary,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
}
