import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/eye_screening_result.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../doctor/widgets/status_badge.dart';
import 'widgets/admin_data_table.dart';

class AdminScreeningsScreen extends StatefulWidget {
  const AdminScreeningsScreen({super.key});

  @override
  State<AdminScreeningsScreen> createState() => _AdminScreeningsScreenState();
}

class _AdminScreeningsScreenState extends State<AdminScreeningsScreen> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _screenings = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _riskFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadScreenings();
  }

  Future<void> _loadScreenings() async {
    setState(() => _isLoading = true);
    try {
      final list = await _adminService.getSystemWideScreenings();
      if (mounted) {
        setState(() {
          _screenings = list;
          _filtered = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilter(String query, String risk) {
    setState(() {
      _searchQuery = query;
      _riskFilter = risk;
      _filtered = _screenings.where((item) {
        final EyeScreeningResult result = item['screening'];
        final patientName = (item['patientName'] ?? '').toString().toLowerCase();

        final matchesQuery = patientName.contains(query.toLowerCase()) ||
            result.observation.toLowerCase().contains(query.toLowerCase()) ||
            result.category.toLowerCase().contains(query.toLowerCase());

        if (risk == 'All') return matchesQuery;
        return matchesQuery && result.riskLevel.name.toLowerCase() == risk.toLowerCase();
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // AI Non-Diagnostic Medical Disclaimer Card
          _buildDisclaimerCard(),
          const SizedBox(height: 20),

          // Main Table Container
          AdminDataTableCard(
            title: 'System-Wide AI Screening Monitoring',
            subtitle: 'Total Diagnostics Executed: ${_screenings.length}',
            searchHint: 'Search patient name or detected condition...',
            onSearchChanged: (val) => _applyFilter(val, _riskFilter),
            headerActions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list, color: AppTheme.primaryNavy),
                onSelected: (val) => _applyFilter(_searchQuery, val),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'All', child: Text('All Risk Levels')),
                  PopupMenuItem(value: 'low', child: Text('Low Risk (Normal)')),
                  PopupMenuItem(value: 'attention', child: Text('Attention Needed')),
                  PopupMenuItem(value: 'high', child: Text('High Risk (Flagged)')),
                ],
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.auto_delete_outlined, color: AppTheme.statusRed, size: 16),
                label: const Text('Data Retention Policy', style: TextStyle(color: AppTheme.statusRed)),
                onPressed: () => _showDataRetentionModal(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.statusRed),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  textStyle: const TextStyle(fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w600),
                ),
              ),
            ],
            child: _isLoading
                ? const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal)))
                : _filtered.isEmpty
                    ? const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('No AI screening records found.', style: TextStyle(color: AppTheme.textLightSecondary, fontFamily: 'Inter'))))
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) => _buildScreeningRow(_filtered[i]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.statusYellow.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.statusYellow.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.statusYellow, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medical Decision-Support Feature Disclaimer',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy, fontFamily: 'Inter'),
                ),
                SizedBox(height: 2),
                Text(
                  'AI screening models provide decision support and triage assistance only. All flagged conditions must be validated by a licensed ophthalmologist or eye specialist.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textLightSecondary, fontFamily: 'Inter', height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreeningRow(Map<String, dynamic> item) {
    final EyeScreeningResult result = item['screening'];
    final String patientName = item['patientName'] ?? 'Patient';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryTeal.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.remove_red_eye, color: AppTheme.primaryTeal, size: 20),
      ),
      title: Row(
        children: [
          Text(
            result.observation,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy, fontFamily: 'Inter'),
          ),
          const SizedBox(width: 10),
          RiskBadge(riskLevel: result.riskLevel.name),
        ],
      ),
      subtitle: Text(
        'Patient: $patientName • Category: ${result.category}\nDate: ${DateFormat('dd MMM yyyy, hh:mm a').format(result.date)} • Confidence: ${(result.confidence * 100).toStringAsFixed(1)}% • Model: ${result.modelVersion}',
        style: const TextStyle(fontSize: 12, color: AppTheme.textLightSecondary, fontFamily: 'Inter', height: 1.4),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6F8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          result.processingStatus.toUpperCase(),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy, fontFamily: 'Inter'),
        ),
      ),
    );
  }

  void _showDataRetentionModal(BuildContext context) {
    final daysCtrl = TextEditingController(text: '180');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Data Retention Policy Action', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Purge old AI screening records older than specified retention days to comply with data privacy policies.',
              style: TextStyle(fontSize: 13, fontFamily: 'Inter'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: daysCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Retention Threshold (Days)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final days = int.tryParse(daysCtrl.text.trim()) ?? 180;
              final purgedCount = await _adminService.purgeScreeningsOlderThan(days);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                _loadScreenings();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Purged $purgedCount old screening records.'),
                    backgroundColor: AppTheme.primaryTeal,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusRed),
            child: const Text('Execute Purge'),
          ),
        ],
      ),
    );
  }
}
