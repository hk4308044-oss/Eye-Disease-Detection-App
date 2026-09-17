import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/user_profile.dart';
import '../../services/firebase_service.dart';
import '../auth/login_screen.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firebaseService = FirebaseService();
  UserProfile? _profile;
  bool _isLoading = true;
  bool _isEditing = false;
  
  // Mock UI state for preferences since they aren't all in UserProfile yet
  bool _notificationsEnabled = true;
  bool _remindersEnabled = true;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _screenTimeController;
  String _selectedGender = 'Male';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _screenTimeController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _firebaseService.getUserProfile();
      if (mounted) {
        setState(() {
          _profile = profile ?? UserProfile.defaultProfile();
          _nameController.text = _profile!.name;
          _ageController.text = _profile!.age.toString();
          _screenTimeController.text = _profile!.averageScreenTimeHours.toString();
          _selectedGender = _profile!.gender.isNotEmpty ? _profile!.gender : 'Male';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _profile = UserProfile.defaultProfile();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final updatedProfile = UserProfile(
        id: _profile!.id,
        name: _nameController.text,
        age: int.tryParse(_ageController.text) ?? _profile!.age,
        gender: _selectedGender,
        wearsGlasses: _profile!.wearsGlasses,
        familyHistory: _profile!.familyHistory,
        averageScreenTimeHours: int.tryParse(_screenTimeController.text) ?? _profile!.averageScreenTimeHours,
        commonSymptoms: _profile!.commonSymptoms,
        eyeHealthScore: _profile!.eyeHealthScore,
        streakDays: _profile!.streakDays,
        role: _profile!.role,
        preferredLanguage: _profile!.preferredLanguage,
        userGoals: _profile!.userGoals,
        hasConsented: _profile!.hasConsented,
      );

      await _firebaseService.saveUserProfile(updatedProfile);
      
      if (mounted) {
        setState(() {
          _profile = updatedProfile;
          _isEditing = false;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile: $e")),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
        content: const Text('Are you sure you want to log out of your account?', style: TextStyle(fontFamily: 'Inter', fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Inter', color: AppTheme.textLightSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _firebaseService.signOut();
      } catch (_) {}
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _showChangePasswordDialog() {
    final email = _firebaseService.currentUser?.email ?? '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Change Password", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
        content: Text(
          email.isNotEmpty 
              ? "We will send a password reset link to your registered email address:\n\n$email\n\nFollow the link in the email to set a new password."
              : "Please ensure you are signed in with a valid email account.",
          style: const TextStyle(fontSize: 14, height: 1.4, color: AppTheme.textLightPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: AppTheme.textLightSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                if (email.isNotEmpty) {
                  await _firebaseService.sendPasswordResetEmail(email);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Password reset email sent to $email"),
                        backgroundColor: AppTheme.primaryTeal,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              }
            },
            child: const Text("Send Reset Email"),
          ),
        ],
      ),
    );
  }

  void _showPrivacySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppTheme.borderLight, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(CupertinoIcons.shield_fill, color: AppTheme.primaryTeal, size: 24),
                const SizedBox(width: 10),
                const Text("Privacy & Security Policy", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: const [
                  SizedBox(height: 8),
                  Text("1. Data Encryption & Protection", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                  SizedBox(height: 6),
                  Text("All user profiles, eye screening images, and clinical histories are encrypted in transit (TLS 1.3) and stored securely in Firebase Firestore.", style: TextStyle(fontSize: 13, color: AppTheme.textLightSecondary, height: 1.4)),
                  SizedBox(height: 16),
                  Text("2. Medical AI Inference Privacy", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                  SizedBox(height: 6),
                  Text("Uploaded eye photos are evaluated solely to calculate visual pattern risk scores. Your visual images are strictly protected and never commercialized.", style: TextStyle(fontSize: 13, color: AppTheme.textLightSecondary, height: 1.4)),
                  SizedBox(height: 16),
                  Text("3. Doctor & Specialist Data Access", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                  SizedBox(height: 6),
                  Text("Only verified eye specialists associated with your booked consultations are authorized to access your diagnostic screening records.", style: TextStyle(fontSize: 13, color: AppTheme.textLightSecondary, height: 1.4)),
                  SizedBox(height: 16),
                  Text("4. Account Control & Erasure", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                  SizedBox(height: 6),
                  Text("You retain total ownership over your personal data. You can clear screening history or request full profile deletion at any time.", style: TextStyle(fontSize: 13, color: AppTheme.textLightSecondary, height: 1.4)),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppTheme.borderLight, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(CupertinoIcons.question_circle_fill, color: AppTheme.primaryTeal, size: 24),
                const SizedBox(width: 10),
                const Text("Help & Support Center", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildFaqItem("How accurate is the AI screening process?", "The AI model performs computer vision pattern analysis to detect visual indicators. It serves as an early decision-support tool and should be confirmed by a licensed eye specialist."),
                  _buildFaqItem("How do I schedule an appointment with a specialist?", "Navigate to the Find Specialist section, search or filter doctors by specialty, pick an available slot, and confirm your booking."),
                  _buildFaqItem("How do I export my PDF screening report?", "Open any completed screening result or report preview, and tap 'Generate PDF Report' or 'Download PDF' to create a printable clinical report."),
                  _buildFaqItem("Who can I contact for support?", "Reach out to our clinical support desk at support@eyecareai.com for any technical assistance."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
          const SizedBox(height: 4),
          Text(answer, style: const TextStyle(fontSize: 13, color: AppTheme.textLightSecondary, height: 1.4)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _screenTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F6F8), // AppTheme.bgLight
        body: const Center(child: CircularProgressIndicator(color: AppTheme.primaryNavy)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text(
          _isEditing ? "Edit Profile" : "Profile",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryNavy,
          ),
        ),
        backgroundColor: const Color(0xFFF4F6F8),
        elevation: 0,
        centerTitle: true,
        actions: [
          if (!_isEditing)
            TextButton(
              onPressed: () => setState(() => _isEditing = true),
              child: const Text(
                "Edit",
                style: TextStyle(
                  color: AppTheme.primaryTeal,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                "Done",
                style: TextStyle(
                  color: AppTheme.primaryTeal,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: _isEditing ? _buildEditForm(theme) : _buildProfileView(theme),
        ),
      ),
    );
  }

  Widget _buildProfileView(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar and Title Section
        Center(
          child: Column(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    )
                  ],
                  border: Border.all(color: AppTheme.borderLight, width: 2),
                ),
                child: const Icon(CupertinoIcons.person_solid, size: 40, color: AppTheme.primaryNavy),
              ),
              const SizedBox(height: 16),
              Text(
                _profile!.name.isEmpty ? "No Name" : _profile!.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _firebaseService.currentUser?.email ?? "No Email",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textLightSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Sections
        _buildSectionHeader(theme, "PERSONAL INFORMATION"),
        _buildCard(
          children: [
            _buildInfoRow("Full Name", _profile!.name.isEmpty ? "Not set" : _profile!.name),
            _buildDivider(),
            _buildInfoRow("Email", _firebaseService.currentUser?.email ?? "Not set"),
            _buildDivider(),
            _buildInfoRow("Age", "${_profile!.age} years"),
            _buildDivider(),
            _buildInfoRow("Gender", _profile!.gender),
          ],
        ),

        const SizedBox(height: 32),
        
        _buildSectionHeader(theme, "MEDICAL & EYE HISTORY"),
        _buildCard(
          children: [
            _buildInfoRow("Wears Glasses/Contacts", _profile!.wearsGlasses ? "Yes" : "No"),
            _buildDivider(),
            _buildInfoRow("Family Eye History", _profile!.familyHistory ? "Yes" : "No"),
            _buildDivider(),
            _buildInfoRow("Diabetes Status", "None"), // Mocked for UI, as per prompt
            _buildDivider(),
            _buildInfoRow("Blood Pressure", "Normal"), // Mocked for UI
            _buildDivider(),
            _buildInfoRow("Previous Eye Conditions", _profile!.commonSymptoms.isEmpty ? "None" : _profile!.commonSymptoms.join(", ")),
          ],
        ),

        const SizedBox(height: 32),

        _buildSectionHeader(theme, "SCREENING PREFERENCES"),
        _buildCard(
          children: [
            _buildToggleRow("Notification preferences", _notificationsEnabled, (val) => setState(() => _notificationsEnabled = val)),
            _buildDivider(),
            _buildToggleRow("Follow-up reminders", _remindersEnabled, (val) => setState(() => _remindersEnabled = val)),
          ],
        ),

        const SizedBox(height: 32),

        _buildSectionHeader(theme, "APP & SECURITY"),
        _buildCard(
          children: [
            _buildActionRow("Change Password", CupertinoIcons.lock, _showChangePasswordDialog),
            _buildDivider(),
            _buildActionRow("Privacy", CupertinoIcons.shield, _showPrivacySheet),
            _buildDivider(),
            _buildActionRow("Help & Information", CupertinoIcons.question_circle, _showHelpSheet),
            _buildDivider(),
            _buildLogoutRow(),
          ],
        ),

        const SizedBox(height: 80), // Padding to ensure bottom navigation remains visible
      ],
    );
  }

  Widget _buildEditForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(theme, "EDIT PERSONAL INFO"),
          _buildCard(
            children: [
              _buildTextField("Full Name", _nameController, keyboardType: TextInputType.name),
              _buildDivider(),
              _buildTextField("Age", _ageController, keyboardType: TextInputType.number),
              _buildDivider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: DropdownButtonFormField<String>(
                  initialValue: ['Male', 'Female', 'Other'].contains(_selectedGender) ? _selectedGender : 'Male',
                  decoration: const InputDecoration(
                    labelText: "Gender",
                    labelStyle: TextStyle(color: AppTheme.textLightSecondary),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.w600, fontSize: 15, fontFamily: 'Inter'),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedGender = val);
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          _buildSectionHeader(theme, "EDIT MEDICAL HISTORY"),
          _buildCard(
            children: [
              _buildTextField("Daily Screen Time (hours)", _screenTimeController, keyboardType: TextInputType.number),
              // We could add more toggles here, but we will preserve existing form fields for now
            ],
          ),
          
          const SizedBox(height: 80), // Bottom nav padding
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 12),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          color: AppTheme.primaryNavy,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.subtleShadowLight,
        border: Border.all(color: AppTheme.borderLight, width: 0.8),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textLightSecondary, // Slate label
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.primaryNavy,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textLightSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.primaryTeal,
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(String label, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: AppTheme.textLightSecondary),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.textLightSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Icon(CupertinoIcons.chevron_forward, size: 16, color: AppTheme.borderLight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutRow() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _logout,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              const Icon(CupertinoIcons.arrow_right_square, size: 20, color: Color(0xFFDC2626)),
              const SizedBox(width: 12),
              const Text(
                "Logout",
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.textLightSecondary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        validator: (value) => value!.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: AppTheme.borderLight, indent: 20);
  }
}
