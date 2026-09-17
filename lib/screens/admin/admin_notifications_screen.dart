import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import 'widgets/admin_data_table.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final AdminService _adminService = AdminService();

  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _targetRole = 'all'; // 'all', 'patient', 'doctor'
  final _targetUidCtrl = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _targetUidCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    if (_titleCtrl.text.trim().isEmpty || _bodyCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide both Title and Message Body.'), backgroundColor: AppTheme.statusRed),
      );
      return;
    }

    setState(() => _isSending = true);
    try {
      await _adminService.sendNotification(
        targetUid: _targetUidCtrl.text.trim().isNotEmpty ? _targetUidCtrl.text.trim() : null,
        targetRole: _targetRole,
        title: _titleCtrl.text.trim(),
        body: _bodyCtrl.text.trim(),
        type: 'announcement',
      );

      if (mounted) {
        setState(() {
          _isSending = false;
          _titleCtrl.clear();
          _bodyCtrl.clear();
          _targetUidCtrl.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification broadcast dispatched successfully!'),
            backgroundColor: AppTheme.statusGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error dispatching notification: $e'), backgroundColor: AppTheme.statusRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          AdminDataTableCard(
            title: 'Broadcast & Targeted System Notifications',
            subtitle: 'Dispatch announcements, reminders, and alerts directly to patient and doctor apps.',
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Target Audience', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy, )),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _targetRole,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Users (Patients & Doctors)')),
                      DropdownMenuItem(value: 'patient', child: Text('All Patients Only')),
                      DropdownMenuItem(value: 'doctor', child: Text('All Doctors Only')),
                    ],
                    onChanged: (val) => setState(() => _targetRole = val ?? 'all'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Specific User UID (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy, )),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _targetUidCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Leave empty to broadcast to selected target audience group',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Notification Title', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy, )),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(hintText: 'e.g. Important System Maintenance Notice'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Message Body', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy, )),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _bodyCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(hintText: 'Enter notification message content...'),
                  ),
                  const SizedBox(height: 24),

                  // Live Preview Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.preview_outlined, color: AppTheme.primaryTeal, size: 18),
                            SizedBox(width: 8),
                            Text('Live App Notification Preview', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryTeal, )),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _titleCtrl.text.isNotEmpty ? _titleCtrl.text : 'Notification Title Placeholder',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy, ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _bodyCtrl.text.isNotEmpty ? _bodyCtrl.text : 'Notification message content will appear here on user devices.',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textLightSecondary, ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: _isSending
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send),
                      label: Text(_isSending ? 'Dispatching Broadcast...' : 'Dispatch Notification Broadcast'),
                      onPressed: _isSending ? null : _sendNotification,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
