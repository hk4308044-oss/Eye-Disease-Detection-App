import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/audit_log.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import 'widgets/admin_data_table.dart';

class AdminAuditLogsScreen extends StatefulWidget {
  const AdminAuditLogsScreen({super.key});

  @override
  State<AdminAuditLogsScreen> createState() => _AdminAuditLogsScreenState();
}

class _AdminAuditLogsScreenState extends State<AdminAuditLogsScreen> {
  final AdminService _adminService = AdminService();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: StreamBuilder<List<AuditLog>>(
        stream: _adminService.streamAuditLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal));
          }

          final logs = snapshot.data ?? [];
          final filtered = logs.where((l) {
            final q = _searchQuery.toLowerCase();
            return l.action.toLowerCase().contains(q) ||
                l.adminName.toLowerCase().contains(q) ||
                l.targetType.toLowerCase().contains(q) ||
                l.details.toLowerCase().contains(q);
          }).toList();

          return AdminDataTableCard(
            title: 'System Security & Administrative Audit Trail',
            subtitle: 'Real-time audit record of all administrative system actions.',
            searchHint: 'Search audit logs by admin name, action, or details...',
            onSearchChanged: (val) => setState(() => _searchQuery = val),
            child: filtered.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text('No audit log entries recorded.', style: TextStyle(color: AppTheme.textLightSecondary, )),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) => _buildAuditRow(filtered[i]),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildAuditRow(AuditLog log) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryNavy.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.history_toggle_off, color: AppTheme.primaryNavy, size: 20),
      ),
      title: Row(
        children: [
          Text(
            log.action,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy, ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              log.targetType,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primaryTeal, ),
            ),
          ),
        ],
      ),
      subtitle: Text(
        'Admin: ${log.adminName} • ${DateFormat('dd MMM yyyy, hh:mm:ss a').format(log.timestamp)}\n${log.details}',
        style: const TextStyle(fontSize: 12, color: AppTheme.textLightSecondary, height: 1.4),
      ),
    );
  }
}
