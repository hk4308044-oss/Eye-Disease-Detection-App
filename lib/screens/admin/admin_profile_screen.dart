import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import 'widgets/admin_data_table.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    _nameCtrl = TextEditingController(text: user?.displayName ?? 'Super Administrator');
    _emailCtrl = TextEditingController(text: user?.email ?? 'admin@visionai.com');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          AdminDataTableCard(
            title: 'Administrator Profile & Security Management',
            subtitle: 'Manage administrative identity, authentication parameters, and security sessions.',
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppTheme.primaryNavy,
                        child: Text(
                          _nameCtrl.text.isNotEmpty ? _nameCtrl.text[0].toUpperCase() : 'A',
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700, ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_nameCtrl.text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy, )),
                          const SizedBox(height: 4),
                          Text(_emailCtrl.text, style: const TextStyle(fontSize: 13, color: AppTheme.textLightSecondary, )),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: AppTheme.primaryTeal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                            child: const Text('SUPER ADMIN ROLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primaryTeal, )),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text('Account Identity', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy, )),
                  const SizedBox(height: 12),
                  TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Display Name')),
                  const SizedBox(height: 12),
                  TextField(controller: _emailCtrl, enabled: false, decoration: const InputDecoration(labelText: 'Email Address (Primary Identity)')),
                  const SizedBox(height: 24),
                  const Text('Session & Security', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy, )),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.security, color: AppTheme.primaryTeal),
                    title: const Text('Authentication Method', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: Text('Firebase Auth UID: ${user?.uid ?? "Local"}', style: const TextStyle(fontSize: 12, )),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.verified_user_outlined, color: AppTheme.statusGreen),
                    title: const Text('Email Verification Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: Text(user?.emailVerified == true ? 'Verified Account' : 'Pending Verification', style: const TextStyle(fontSize: 12, )),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout, color: AppTheme.statusRed),
                      label: const Text('Sign Out of Admin Portal', style: TextStyle(color: AppTheme.statusRed)),
                      onPressed: () => _confirmSignOut(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.statusRed),
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

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Admin Portal Sign Out', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to end your administrative session?', style: TextStyle()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusRed),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _auth.signOut();
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}
