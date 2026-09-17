import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/doctor_profile.dart';
import '../../services/doctor_service.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final DoctorService _service = DoctorService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DoctorProfile? _profile;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;

  // Form controllers
  late TextEditingController _nameCtrl;
  late TextEditingController _specializationCtrl;
  late TextEditingController _qualificationCtrl;
  late TextEditingController _licenseCtrl;
  late TextEditingController _clinicCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _feeCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _expCtrl;
  bool _isAvailable = true;
  bool _offersOnline = true;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadProfile();
  }

  void _initControllers() {
    _nameCtrl = TextEditingController();
    _specializationCtrl = TextEditingController();
    _qualificationCtrl = TextEditingController();
    _licenseCtrl = TextEditingController();
    _clinicCtrl = TextEditingController();
    _locationCtrl = TextEditingController();
    _feeCtrl = TextEditingController();
    _bioCtrl = TextEditingController();
    _expCtrl = TextEditingController();
  }

  void _fillControllers(DoctorProfile p) {
    _nameCtrl.text = p.name;
    _specializationCtrl.text = p.specialization;
    _qualificationCtrl.text = p.qualification;
    _licenseCtrl.text = p.licenseNumber;
    _clinicCtrl.text = p.clinicName;
    _locationCtrl.text = p.clinicLocation;
    _feeCtrl.text = p.consultationFee.toStringAsFixed(0);
    _bioCtrl.text = p.bio;
    _expCtrl.text = p.experienceYears.toString();
    _isAvailable = p.isAvailable;
    _offersOnline = p.offersOnlineConsultation;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _specializationCtrl.dispose();
    _qualificationCtrl.dispose();
    _licenseCtrl.dispose();
    _clinicCtrl.dispose();
    _locationCtrl.dispose();
    _feeCtrl.dispose();
    _bioCtrl.dispose();
    _expCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _service.getDoctorProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
          if (profile != null) _fillControllers(profile);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to load profile: $e'),
          backgroundColor: AppTheme.statusRed,
        ));
      }
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final downloadUrl = await _service.uploadProfileImage(File(pickedFile.path));
      if (mounted && downloadUrl != null && _profile != null) {
        setState(() {
          _profile = _profile!.copyWith(profileImageUrl: downloadUrl);
          _isUploadingPhoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profile photo updated successfully.'),
          backgroundColor: AppTheme.statusGreen,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to upload photo: $e'),
          backgroundColor: AppTheme.statusRed,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_profile == null) return;

    // Validation
    final name = _nameCtrl.text.trim();
    final spec = _specializationCtrl.text.trim();
    final license = _licenseCtrl.text.trim();
    final fee = double.tryParse(_feeCtrl.text.trim());
    final exp = int.tryParse(_expCtrl.text.trim());

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter your full name.'),
        backgroundColor: AppTheme.statusRed,
      ));
      return;
    }
    if (spec.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter your specialization.'),
        backgroundColor: AppTheme.statusRed,
      ));
      return;
    }
    if (license.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter your medical license number.'),
        backgroundColor: AppTheme.statusRed,
      ));
      return;
    }
    if (fee == null || fee < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter a valid consultation fee.'),
        backgroundColor: AppTheme.statusRed,
      ));
      return;
    }
    if (exp == null || exp < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter valid years of experience.'),
        backgroundColor: AppTheme.statusRed,
      ));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updated = _profile!.copyWith(
        name: name,
        specialization: spec,
        qualification: _qualificationCtrl.text.trim(),
        licenseNumber: license,
        clinicName: _clinicCtrl.text.trim(),
        clinicLocation: _locationCtrl.text.trim(),
        consultationFee: fee,
        bio: _bioCtrl.text.trim(),
        experienceYears: exp,
        isAvailable: _isAvailable,
        offersOnlineConsultation: _offersOnline,
      );

      await _service.saveDoctorProfile(updated);

      if (mounted) {
        setState(() {
          _profile = updated;
          _isEditing = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profile updated successfully.'),
          backgroundColor: AppTheme.statusGreen,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error saving profile: $e'),
          backgroundColor: AppTheme.statusRed,
        ));
      }
    }
  }

  void _showChangePasswordDialog() {
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool isChanging = false;
    bool obscureCurrent = true;
    bool obscureNew = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.lock_outline, color: AppTheme.primaryTeal),
              SizedBox(width: 10),
              Text('Change Password', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPassCtrl,
                  obscureText: obscureCurrent,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: const Icon(Icons.key, size: 18, color: AppTheme.primaryTeal),
                    suffixIcon: IconButton(
                      icon: Icon(obscureCurrent ? Icons.visibility_off : Icons.visibility, size: 18),
                      onPressed: () => setDialogState(() => obscureCurrent = !obscureCurrent),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPassCtrl,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock_reset, size: 18, color: AppTheme.primaryTeal),
                    suffixIcon: IconButton(
                      icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility, size: 18),
                      onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPassCtrl,
                  obscureText: obscureNew,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: Icon(Icons.check_circle_outline, size: 18, color: AppTheme.primaryTeal),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isChanging ? null : () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isChanging
                  ? null
                  : () async {
                      final currentPass = currentPassCtrl.text;
                      final newPass = newPassCtrl.text;
                      final confirmPass = confirmPassCtrl.text;

                      if (currentPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Please fill in all password fields.'),
                          backgroundColor: AppTheme.statusRed,
                        ));
                        return;
                      }

                      if (newPass.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('New password must be at least 6 characters long.'),
                          backgroundColor: AppTheme.statusRed,
                        ));
                        return;
                      }

                      if (newPass != confirmPass) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('New passwords do not match.'),
                          backgroundColor: AppTheme.statusRed,
                        ));
                        return;
                      }

                      setDialogState(() => isChanging = true);

                      try {
                        final user = _auth.currentUser;
                        if (user == null || user.email == null) {
                          throw Exception('No authenticated user session found.');
                        }

                        // Re-authenticate
                        final cred = EmailAuthProvider.credential(
                          email: user.email!,
                          password: currentPass,
                        );
                        await user.reauthenticateWithCredential(cred);
                        await user.updatePassword(newPass);

                        if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Password changed successfully.'),
                            backgroundColor: AppTheme.statusGreen,
                            behavior: SnackBarBehavior.floating,
                          ));
                        }
                      } on FirebaseAuthException catch (e) {
                        setDialogState(() => isChanging = false);
                        String errMessage = e.message ?? 'Password update failed.';
                        if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
                          errMessage = 'Current password is incorrect.';
                        }
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(errMessage),
                            backgroundColor: AppTheme.statusRed,
                          ));
                        }
                      } catch (e) {
                        setDialogState(() => isChanging = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Error updating password: $e'),
                            backgroundColor: AppTheme.statusRed,
                          ));
                        }
                      }
                    },
              child: isChanging
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Update Password'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryTeal));
    }

    if (_profile == null) {
      return _buildNoProfile();
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          _buildProfileHeader(),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              children: [
                if (_isEditing) _buildEditForm() else _buildViewMode(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF0891B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Avatar with photo pick button
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                backgroundImage: _profile?.profileImageUrl != null &&
                        _profile!.profileImageUrl!.isNotEmpty
                    ? NetworkImage(_profile!.profileImageUrl!)
                    : null,
                child: _isUploadingPhoto
                    ? const CircularProgressIndicator(color: Colors.white)
                    : (_profile?.profileImageUrl == null || _profile!.profileImageUrl!.isEmpty)
                        ? Text(
                            _profile?.name.isNotEmpty == true
                                ? _profile!.name[0].toUpperCase()
                                : 'D',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              ),
                          )
                        : null,
              ),
              GestureDetector(
                onTap: _isUploadingPhoto ? null : _pickAndUploadPhoto,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Dr. ${_profile!.name}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _profile!.specialization,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 14,
              ),
          ),
          const SizedBox(height: 4),
          Text(
            _profile!.qualification,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 12,
              ),
          ),
          const SizedBox(height: 14),
          // Action buttons
          if (!_isEditing)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _headerBtn('Edit Profile', Icons.edit_outlined, () {
                  setState(() => _isEditing = true);
                }),
                const SizedBox(width: 12),
                _headerBtn('Sign Out', Icons.logout, _confirmSignOut,
                    color: Colors.redAccent),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _headerBtn('Cancel', Icons.close, () {
                  setState(() {
                    _isEditing = false;
                    if (_profile != null) _fillControllers(_profile!);
                  });
                }),
                const SizedBox(width: 12),
                _headerBtn(
                    _isSaving ? 'Saving...' : 'Save Changes',
                    Icons.check,
                    _isSaving ? null : _saveProfile),
              ],
            ),
        ],
      ),
    );
  }

  Widget _headerBtn(String label, IconData icon, VoidCallback? onTap,
      {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: (color ?? Colors.white).withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color ?? Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color ?? Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewMode() {
    final user = _auth.currentUser;
    final isEmailVerified = user?.emailVerified ?? false;

    return Column(
      children: [
        _infoCard('Professional Info', [
          _infoRow(Icons.badge_outlined, 'Medical License', _profile!.licenseNumber),
          _infoRow(Icons.local_hospital_outlined, 'Clinic / Hospital', _profile!.clinicName),
          _infoRow(Icons.location_on_outlined, 'Location', _profile!.clinicLocation),
          _infoRow(Icons.payments_outlined, 'Consultation Fee',
              'PKR ${_profile!.consultationFee.toStringAsFixed(0)}'),
          _infoRow(Icons.work_outline, 'Experience',
              '${_profile!.experienceYears} years'),
        ]),
        const SizedBox(height: 16),
        _infoCard('Account & Security', [
          _infoRow(Icons.email_outlined, 'Account Email', user?.email ?? _profile!.email),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined, size: 18, color: AppTheme.primaryTeal),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email Verification Status',
                        style: TextStyle(fontSize: 11, color: AppTheme.textLightSecondary, ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isEmailVerified ? AppTheme.statusGreen.withValues(alpha: 0.12) : Colors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isEmailVerified ? Icons.check_circle : Icons.warning_amber_rounded,
                                  size: 12,
                                  color: isEmailVerified ? AppTheme.statusGreen : Colors.amber[800],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isEmailVerified ? 'Verified Account' : 'Unverified Email',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isEmailVerified ? AppTheme.statusGreen : Colors.amber[900],
                                    ),
                                ),
                              ],
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
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Icon(Icons.security_outlined, size: 18, color: AppTheme.primaryTeal),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account Role',
                      style: TextStyle(fontSize: 11, color: AppTheme.textLightSecondary, ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Doctor Portal',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryTeal,
                          ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.lock_reset, size: 18),
              label: const Text('Change Password'),
              onPressed: _showChangePasswordDialog,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: AppTheme.primaryTeal),
                foregroundColor: AppTheme.primaryTeal,
              ),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        _infoCard('Availability & Services', [
          _switchRow('Available for Appointments', _isAvailable, (v) async {
            setState(() => _isAvailable = v);
            await _service.setAvailability(v);
          }),
          _switchRow('Online Consultations', _offersOnline, (v) async {
            setState(() => _offersOnline = v);
            final updated = _profile!.copyWith(offersOnlineConsultation: v);
            await _service.saveDoctorProfile(updated);
            setState(() => _profile = updated);
          }),
        ]),
        if (_profile!.bio.isNotEmpty) ...[
          const SizedBox(height: 16),
          _infoCard('About Doctor', [
            Text(
              _profile!.bio,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textLightSecondary,
                height: 1.5,
              ),
            ),
          ]),
        ],
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        _editCard('Personal Information', [
          _field('Full Name *', _nameCtrl, Icons.person_outline),
          _field('Specialization *', _specializationCtrl, Icons.medical_services_outlined),
          _field('Qualification', _qualificationCtrl, Icons.school_outlined),
          _field('Years of Experience', _expCtrl, Icons.work_outline,
              inputType: TextInputType.number),
          _field('Bio / About', _bioCtrl, Icons.info_outline, maxLines: 3),
        ]),
        const SizedBox(height: 16),
        _editCard('Practice Details', [
          _field('Medical License No. *', _licenseCtrl, Icons.badge_outlined),
          _field('Clinic / Hospital', _clinicCtrl, Icons.local_hospital_outlined),
          _field('Location', _locationCtrl, Icons.location_on_outlined),
          _field('Consultation Fee (PKR)', _feeCtrl, Icons.payments_outlined,
              inputType: TextInputType.number),
        ]),
        const SizedBox(height: 16),
        _editCard('Availability', [
          _switchRow('Available for Appointments', _isAvailable,
              (v) => setState(() => _isAvailable = v)),
          _switchRow('Online Consultations', _offersOnline,
              (v) => setState(() => _offersOnline = v)),
        ]),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.save_outlined),
            label: Text(_isSaving ? 'Saving...' : 'Save Profile Changes'),
            onPressed: _isSaving ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoCard(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryNavy,
                ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _editCard(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryNavy,
                ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryTeal),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textLightSecondary,
                    ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryNavy,
                    ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _switchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.primaryNavy,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.primaryTeal,
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18, color: AppTheme.primaryTeal),
        ),
      ),
    );
  }

  Widget _buildNoProfile() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_off_outlined,
                size: 56, color: AppTheme.textLightDisabled),
            const SizedBox(height: 16),
            const Text(
              'Doctor Profile Not Initialized',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryNavy,
                ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap below to reload or set up your doctor profile.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textLightSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Loading Profile'),
              onPressed: _loadProfile,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.logout, color: AppTheme.statusRed),
              label: const Text('Sign Out',
                  style: TextStyle(color: AppTheme.statusRed)),
              onPressed: _confirmSignOut,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.statusRed),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to sign out of Doctor Portal?',
            style: TextStyle()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusRed),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}
