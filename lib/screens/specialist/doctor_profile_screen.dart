import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/specialist_models.dart';
import '../../theme/app_theme.dart';
import '../../services/messaging_service.dart';
import '../messaging/chat_screen.dart';
import 'appointment_booking_screen.dart';

class DoctorProfileScreen extends StatelessWidget {
  final DoctorModel doctor;
  final bool openBooking;

  const DoctorProfileScreen({super.key, required this.doctor, this.openBooking = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Auto-open booking if triggered from "Book" button
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (openBooking) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => AppointmentBookingScreen(doctor: doctor)));
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Premium Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.primaryNavy,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppTheme.primaryNavy,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                      ),
                      child: Center(
                        child: Text(doctor.avatarInitials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(doctor.name, style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                        if (doctor.isVerified) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.verified_rounded, color: AppTheme.aiTeal, size: 20),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(doctor.specialty, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.7))),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Stats
                  Row(
                    children: [
                      _buildStatCard(theme, '${doctor.rating}', 'Rating', Icons.star_rounded, const Color(0xFFD97706)),
                      const SizedBox(width: 12),
                      _buildStatCard(theme, '${doctor.reviewCount}', 'Reviews', CupertinoIcons.chat_bubble_text, AppTheme.primaryTeal),
                      const SizedBox(width: 12),
                      _buildStatCard(theme, '${doctor.experienceYears} yrs', 'Exp.', Icons.workspace_premium_rounded, AppTheme.primaryNavy),
                    ],
                  ),

                  const SizedBox(height: 24),
                  _buildSectionCard(theme, 'About', [
                    _buildInfoRow(theme, 'Qualifications', doctor.qualifications),
                    _buildInfoRow(theme, 'Clinic', doctor.clinic),
                    _buildInfoRow(theme, 'Address', doctor.address),
                    _buildInfoRow(theme, 'Distance', doctor.distance),
                    _buildInfoRow(theme, 'Consultation Fee', 'PKR ${doctor.consultationFee.toStringAsFixed(0)}'),
                  ]),

                  const SizedBox(height: 16),
                  _buildSectionCard(theme, 'Consultation Types', [
                    _buildFeatureRow(theme, 'Clinic Visit', CupertinoIcons.building_2_fill, true),
                    const Divider(color: AppTheme.borderLight, height: 1),
                    _buildFeatureRow(theme, 'Online Consultation', CupertinoIcons.video_camera_solid, doctor.offersOnlineConsultation),
                  ]),

                  const SizedBox(height: 16),
                  _buildSectionCard(theme, 'Availability', [
                    _buildAvailableDays(theme),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: doctor.availableSlots.map((slot) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.bgSecondary,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Text(slot, style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.primaryNavy, fontWeight: FontWeight.w600)),
                      )).toList(),
                    ),
                  ]),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      // Message button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            try {
                              final messagingService = MessagingService();
                              final convo = await messagingService.getOrCreateConversation(
                                doctorId: doctor.id,
                                doctorName: doctor.name,
                                doctorSpecialty: doctor.specialty,
                              );
                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      conversationId: convo.id,
                                      receiverId: doctor.id,
                                      receiverName: doctor.name,
                                      receiverSpecialty: doctor.specialty,
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Could not start chat: $e')),
                                );
                              }
                            }
                          },
                          icon: const Icon(CupertinoIcons.chat_bubble, size: 18),
                          label: const Text('Message'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: AppTheme.primaryTeal),
                            foregroundColor: AppTheme.primaryTeal,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AppointmentBookingScreen(doctor: doctor))),
                          icon: const Icon(Icons.calendar_today_outlined, size: 18),
                          label: const Text('Book Appointment'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: AppTheme.primaryTeal,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderLight, width: 0.8),
          boxShadow: AppTheme.subtleShadowLight,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
            Text(label, style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.textLightSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(ThemeData theme, String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight, width: 0.8),
        boxShadow: AppTheme.subtleShadowLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textLightSecondary)),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.primaryNavy, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(ThemeData theme, String label, IconData icon, bool available) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: available ? AppTheme.primaryTeal : AppTheme.borderLight),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.primaryNavy, fontWeight: FontWeight.w500))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: available ? AppTheme.statusGreen.withValues(alpha: 0.1) : AppTheme.bgSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              available ? 'Available' : 'Not Available',
              style: theme.textTheme.labelSmall?.copyWith(
                color: available ? AppTheme.statusGreen : AppTheme.textLightDisabled,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableDays(ThemeData theme) {
    return Row(
      children: doctor.availableDays.map((day) => Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primaryTeal.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.3)),
        ),
        child: Text(day, style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
      )).toList(),
    );
  }
}
