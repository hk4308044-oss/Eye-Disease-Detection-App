import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/specialist_models.dart';
import '../../theme/app_theme.dart';
import 'doctor_profile_screen.dart';

class FindSpecialistScreen extends StatefulWidget {
  /// Optional category from an AI screening result, e.g. "Glaucoma"
  final String? screeningCategory;

  const FindSpecialistScreen({super.key, this.screeningCategory});

  @override
  State<FindSpecialistScreen> createState() => _FindSpecialistScreenState();
}

class _FindSpecialistScreenState extends State<FindSpecialistScreen> {
  String _activeFilter = 'Highest Rated';
  final String _location = 'Karachi, Pakistan'; // Mock location

  final List<String> _filters = [
    'Nearest',
    'Highest Rated',
    'Most Experienced',
    'Available Today',
    'Lowest Fee',
    'Online Consultation',
    'Female Doctor',
  ];

  String get _recommendedSpecialty {
    final cat = widget.screeningCategory?.toLowerCase() ?? '';
    if (cat.contains('glaucoma')) return 'Glaucoma & Ophthalmology';
    if (cat.contains('diabetic') || cat.contains('retinopathy')) return 'Retina & Ophthalmology';
    if (cat.contains('cataract')) return 'Cataract & Refractive Surgery';
    if (cat.contains('conjunctivitis')) return 'Comprehensive Ophthalmology';
    return '';
  }

  List<DoctorModel> get _filteredDoctors {
    List<DoctorModel> doctors = List.from(DemoSpecialistData.allDoctors);
    switch (_activeFilter) {
      case 'Available Today':
        doctors = doctors.where((d) => d.isAvailableToday).toList();
        break;
      case 'Online Consultation':
        doctors = doctors.where((d) => d.offersOnlineConsultation).toList();
        break;
      case 'Female Doctor':
        doctors = doctors.where((d) => d.isFemale).toList();
        break;
      case 'Nearest':
        doctors.sort((a, b) => a.distance.compareTo(b.distance));
        break;
      case 'Highest Rated':
        doctors.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Most Experienced':
        doctors.sort((a, b) => b.experienceYears.compareTo(a.experienceYears));
        break;
      case 'Lowest Fee':
        doctors.sort((a, b) => a.consultationFee.compareTo(b.consultationFee));
        break;
    }
    return doctors;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recommended = _recommendedSpecialty;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text('Find Your Eye Specialist', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
        backgroundColor: AppTheme.bgLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryNavy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Find a suitable eye specialist near you.', style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textLightSecondary)),
                const SizedBox(height: 16),

                // Location row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderLight),
                    boxShadow: AppTheme.subtleShadowLight,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: AppTheme.primaryTeal, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Current Location', style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.textLightDisabled)),
                            Text(_location, style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.primaryNavy, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                        child: Text('Change', style: theme.textTheme.labelMedium?.copyWith(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

                // AI Recommendation Banner
                if (recommended.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTeal,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.aiTeal.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(CupertinoIcons.sparkles, color: AppTheme.primaryTeal, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.primaryNavy, height: 1.5),
                              children: [
                                const TextSpan(text: 'Based on your screening result, consultation with a '),
                                TextSpan(text: recommended, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                                const TextSpan(text: ' specialist may be appropriate.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // DEMO Banner
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF9C3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFDE047).withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 14, color: Color(0xFFB45309)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'DEMO DATA — Profiles shown are illustrative only and not real medical practitioners.',
                          style: theme.textTheme.labelSmall?.copyWith(color: const Color(0xFFB45309)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Horizontal Filter Chips
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isActive = _activeFilter == filter;
                return GestureDetector(
                  onTap: () => setState(() => _activeFilter = filter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.primaryNavy : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isActive ? AppTheme.primaryNavy : AppTheme.borderLight),
                    ),
                    child: Text(
                      filter,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isActive ? Colors.white : AppTheme.textLightSecondary,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Doctor List
          Expanded(
            child: _filteredDoctors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(CupertinoIcons.person_2, size: 48, color: AppTheme.borderLight),
                        const SizedBox(height: 16),
                        Text('No specialists found', style: theme.textTheme.titleMedium?.copyWith(color: AppTheme.textLightSecondary)),
                        Text('Try a different filter', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _filteredDoctors.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, index) => _buildDoctorCard(context, _filteredDoctors[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, DoctorModel doctor) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.subtleShadowLight,
        border: Border.all(color: AppTheme.borderLight, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNavy,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(doctor.avatarInitials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(doctor.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                          ),
                          if (doctor.isVerified) ...[
                            const Icon(Icons.verified_rounded, color: AppTheme.primaryTeal, size: 16),
                            const SizedBox(width: 4),
                            Text('Verified', style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(doctor.specialty, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.primaryTeal, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(doctor.qualifications, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textLightSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildMetaChip(context, Icons.star_rounded, '${doctor.rating} (${doctor.reviewCount})', const Color(0xFFD97706)),
                _buildMetaChip(context, CupertinoIcons.clock, '${doctor.experienceYears} yrs exp', AppTheme.textLightSecondary),
                _buildMetaChip(context, Icons.location_on_outlined, doctor.distance, AppTheme.textLightSecondary),
                _buildMetaChip(context, CupertinoIcons.money_dollar_circle, 'PKR ${doctor.consultationFee.toStringAsFixed(0)}', AppTheme.textLightSecondary),
                if (doctor.isAvailableToday)
                  _buildMetaChip(context, Icons.circle, 'Available Today', AppTheme.statusGreen),
                if (doctor.offersOnlineConsultation)
                  _buildMetaChip(context, Icons.videocam_outlined, 'Online', AppTheme.primaryTeal),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorProfileScreen(doctor: doctor))),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppTheme.borderLight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('View Profile', style: theme.textTheme.labelLarge?.copyWith(color: AppTheme.primaryNavy)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorProfileScreen(doctor: doctor, openBooking: true))),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: AppTheme.primaryTeal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text('Book', style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaChip(BuildContext context, IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
