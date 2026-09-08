import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/eye_screening_result.dart';
import '../eye_screening/screening_result_screen.dart';
import '../screening/image_capture_screen.dart';
import '../../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<EyeScreeningResult> _screenings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('screenings')
          .orderBy('date', descending: true)
          .get();

      if (mounted) {
        setState(() {
          _screenings = snapshot.docs.map((doc) => EyeScreeningResult.fromFirestore(doc.data(), doc.id)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading history: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getSeverityColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return const Color(0xFF16A34A);
      case RiskLevel.attention:
        return const Color(0xFFD97706);
      case RiskLevel.high:
        return const Color(0xFFDC2626);
    }
  }

  String _getSeverityLabel(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return "Mild Risk";
      case RiskLevel.attention:
        return "Moderate Risk";
      case RiskLevel.high:
        return "Severe Risk";
    }
  }

  IconData _getSeverityIcon(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return Icons.verified_rounded;
      case RiskLevel.attention:
        return Icons.warning_rounded;
      case RiskLevel.high:
        return Icons.error_rounded;
    }
  }

  void _showCompareScreeningsModal(BuildContext context) {
    if (_screenings.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least 2 screening records are required to perform a comparison.'),
          backgroundColor: AppTheme.primaryNavy,
        ),
      );
      return;
    }

    final latest = _screenings.first;
    final previous = _screenings[1];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppTheme.borderLight, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Icon(Icons.compare_arrows_rounded, color: AppTheme.primaryTeal),
                  const SizedBox(width: 8),
                  const Text(
                    'Screening Progression Comparison',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primaryNavy, fontFamily: 'Inter'),
                  ),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close, color: AppTheme.textLightSecondary), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    children: [
                      Expanded(child: _compareCard('PREVIOUS SCAN', previous)),
                      const SizedBox(width: 12),
                      Expanded(child: _compareCard('LATEST SCAN', latest)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('AI Diagnostic Progression', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy, fontFamily: 'Inter')),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.bgSecondary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Text(
                      latest.riskLevel == previous.riskLevel
                          ? 'Your risk level has remained stable (${_getSeverityLabel(latest.riskLevel)}) between scans.'
                          : 'Your risk status shifted from ${_getSeverityLabel(previous.riskLevel)} to ${_getSeverityLabel(latest.riskLevel)}.',
                      style: const TextStyle(fontSize: 13, color: AppTheme.primaryNavy, fontFamily: 'Inter', height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _compareCard(String title, EyeScreeningResult scan) {
    final color = _getSeverityColor(scan.riskLevel);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.subtleShadowLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textLightSecondary, fontFamily: 'Inter')),
          const SizedBox(height: 6),
          Text(DateFormat('dd MMM yyyy').format(scan.date), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy, fontFamily: 'Inter')),
          const SizedBox(height: 10),
          Text(scan.observation, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.primaryNavy, fontFamily: 'Inter')),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(_getSeverityLabel(scan.riskLevel), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color, fontFamily: 'Inter')),
          ),
          const SizedBox(height: 8),
          Text('Confidence: ${scan.confidence.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 11, color: AppTheme.textLightSecondary, fontFamily: 'Inter')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text(
          "Screening History",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryNavy,
          ),
        ),
        backgroundColor: AppTheme.bgLight,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryNavy))
          : _screenings.isEmpty
              ? _buildEmptyState(theme)
              : _buildHistoryContent(theme),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.bgSecondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.doc_text_search, size: 64, color: AppTheme.textLightDisabled),
            ),
            const SizedBox(height: 24),
            Text(
              "No screenings yet",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Your completed screenings will appear here.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textLightSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ImageCaptureScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Start Your First Screening", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryContent(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _loadHistory,
      color: AppTheme.primaryNavy,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        children: [
          _buildSummaryCard(theme),
          
          const SizedBox(height: 32),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Screening Records",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryNavy,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showCompareScreeningsModal(context),
                icon: const Icon(Icons.compare_arrows_rounded, size: 18),
                label: const Text("Compare"),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryTeal,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          ..._screenings.map((record) => _buildRecordCard(theme, record)),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme) {
    final latestScreening = _screenings.first;
    final latestRiskColor = _getSeverityColor(latestScreening.riskLevel);

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
            children: [
              const Icon(CupertinoIcons.chart_bar_alt_fill, color: AppTheme.primaryTeal, size: 20),
              const SizedBox(width: 12),
              Text(
                "Your Eye Health Journey",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Colors.white24, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryMetric(theme, "Total Screenings", "${_screenings.length}", Colors.white),
              Container(height: 40, width: 1, color: Colors.white24),
              _buildSummaryMetric(theme, "Last Screening", DateFormat('MMM d, yyyy').format(latestScreening.date), Colors.white),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: latestRiskColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: latestRiskColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(_getSeverityIcon(latestScreening.riskLevel), color: latestRiskColor, size: 20),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Latest Risk Status",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      _getSeverityLabel(latestScreening.riskLevel),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: latestRiskColor,
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
    );
  }

  Widget _buildSummaryMetric(ThemeData theme, String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white70,
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

  Widget _buildRecordCard(ThemeData theme, EyeScreeningResult record) {
    final riskColor = _getSeverityColor(record.riskLevel);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.subtleShadowLight,
        border: Border.all(color: AppTheme.borderLight, width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ScreeningResultScreen(result: record)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMMM d, yyyy • h:mm a').format(record.date),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.textLightSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textLightDisabled),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: riskColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_getSeverityIcon(record.riskLevel), color: riskColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.observation,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                "Confidence: ${record.confidence.toStringAsFixed(1)}%",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textLightSecondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: riskColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getSeverityLabel(record.riskLevel),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: riskColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
