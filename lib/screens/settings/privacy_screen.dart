import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../services/firebase_service.dart';
import '../../services/export_service.dart';
import '../auth/login_screen.dart'; // Ensure this path exists or adjust
import 'manage_images_screen.dart';
import 'accessibility_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../../theme/app_theme.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final ExportService _exportService = ExportService();

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _hideLoadingDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _handleClearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear History"),
        content: const Text("Are you sure you want to delete all screening history? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              _showLoadingDialog();
              try {
                await _firebaseService.deleteScreeningHistory();
                if (mounted) {
                  _hideLoadingDialog();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Screening history cleared.")));
                }
              } catch (e) {
                if (mounted) {
                  _hideLoadingDialog();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _handleDownloadData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Download My Data"),
        content: const Text("Choose format to download your data."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              _showLoadingDialog();
              try {
                await _exportService.exportDataAsJson();
                if (mounted) _hideLoadingDialog();
              } catch (e) {
                if (mounted) {
                  _hideLoadingDialog();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              }
            },
            child: const Text("JSON"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              _showLoadingDialog();
              try {
                await _exportService.exportDataAsPdf();
                if (mounted) _hideLoadingDialog();
              } catch (e) {
                if (mounted) {
                  _hideLoadingDialog();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              }
            },
            child: const Text("PDF"),
          ),
        ],
      ),
    );
  }

  void _handleDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete your account and all data?"),
        content: const Text("This action is permanent and cannot be undone. All your screening history, images, and profile data will be permanently deleted."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              _showLoadingDialog();
              try {
                await _firebaseService.deleteAccountAndData();
                if (mounted) {
                  _hideLoadingDialog();
                  // Navigate to Login
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (mounted) {
                  _hideLoadingDialog();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e (You may need to re-authenticate)")));
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete Everything"),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              _showLoadingDialog();
              try {
                await _firebaseService.signOut();
                if (mounted) {
                  _hideLoadingDialog();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (mounted) {
                  _hideLoadingDialog();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.primaryBlue),
            child: const Text("Log Out"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background, // White background per design
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(
              color: AppTheme.softBlue, // Light grayish blue
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.darkNavy, size: 18),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: const Text(
          "Settings & Privacy",
          style: TextStyle(
            color: AppTheme.darkNavy,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Section 1: About the AI Model
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.softBlue, // Light blue
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.data_object, color: AppTheme.primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                "About the AI Model",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: "How it works",
            description: "Our AI uses deep convolutional neural networks to analyze texture, color variance, and vascular patterns in the iris and lens region. It is trained on over 500,000 clinically validated eye images.",
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            title: "Understanding Confidence",
            description: "Confidence scores (e.g., 92%) indicate how closely your eye features match patterns in our training set. It is not a measure of disease severity or a probability of diagnosis.",
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.statusYellow.withValues(alpha: 0.1), // Light yellow/amber
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.statusYellow.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.warning_amber_rounded, color: AppTheme.statusYellow, size: 18),
                    SizedBox(width: 8),
                    Text(
                      "AI Limitations",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkNavy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "AI screening can result in false positives or false negatives. Factors like poor lighting, blur, or complex eye conditions may affect accuracy. A professional clinical examination is always required for diagnosis.",
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Section 2: Privacy Center
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.statusGreen.withValues(alpha: 0.1), // Light green
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.security, color: AppTheme.statusGreen, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                "Privacy Center",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.softBlue),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildListTile(
                  icon: CupertinoIcons.eye_slash,
                  title: "Manage Eye Images",
                  subtitle: "View or delete individual captured images",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageImagesScreen()));
                  },
                ),
                const Divider(height: 1, color: AppTheme.softBlue),
                _buildListTile(
                  icon: CupertinoIcons.time,
                  title: "Clear History",
                  subtitle: "Delete all screening records and analysis",
                  onTap: _handleClearHistory,
                ),
                const Divider(height: 1, color: AppTheme.softBlue),
                _buildListTile(
                  icon: CupertinoIcons.doc_text,
                  title: "Download My Data",
                  subtitle: "Get a copy of all your health data in JSON/PDF",
                  onTap: _handleDownloadData,
                ),
                const Divider(height: 1, color: AppTheme.softBlue),
                _buildListTile(
                  icon: Icons.logout,
                  title: "Log Out",
                  subtitle: "Sign out of your account on this device",
                  onTap: _handleLogout,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Section: General Settings
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.settings, color: AppTheme.primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                "General Settings",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.softBlue),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildListTile(
                  icon: Icons.accessibility_new,
                  title: "Accessibility",
                  subtitle: "Adjust text scale, contrast, and visual settings",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AccessibilityScreen()));
                  },
                ),
                const Divider(height: 1, color: AppTheme.softBlue),
                _buildListTile(
                  icon: Icons.admin_panel_settings,
                  title: "Admin Dashboard",
                  subtitle: "View analytics and system metrics",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          
          // Section 3: How we handle your data
          const Text(
            "How we handle your data",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkNavy,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.softBlue, // Light blue background
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildNumberedItem(1, "Images are encrypted locally before being transmitted for analysis via a secure SSL tunnel."),
                const SizedBox(height: 16),
                _buildNumberedItem(2, "We use de-identified data for model improvement only if you opt-in."),
                const SizedBox(height: 16),
                _buildNumberedItem(3, "No data is shared with third-party advertisers or insurance companies."),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Delete Account Button
          InkWell(
            onTap: _handleDeleteAccount,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.statusRed.withValues(alpha: 0.1), // Light red
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text(
                "Delete Account & All Data",
                style: TextStyle(
                  color: AppTheme.statusRed, // Red text
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "This action is permanent and cannot be undone. All screening history and images will be wiped from our servers.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textDisabled, // Muted grey
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // Very light grayish blue
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkNavy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textDisabled, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textDisabled,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.textDisabled.withValues(alpha: 0.5), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberedItem(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number.toString(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue, // Blue
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
