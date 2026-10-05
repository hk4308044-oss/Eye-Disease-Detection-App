import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fyp_flutter/widgets/healthcare_components.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HealthcareColors.bgLightGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildUpcomingAppointment(),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildTopDoctors(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning,',
              style: GoogleFonts.plusJakartaSans(
                color: HealthcareColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Alex Johnson',
              style: GoogleFonts.plusJakartaSans(
                color: HealthcareColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const CircleAvatar(
          radius: 24,
          backgroundColor: HealthcareColors.softCyan,
          child: Icon(Icons.person, color: HealthcareColors.primaryTeal),
        ),
      ],
    );
  }

  Widget _buildUpcomingAppointment() {
    return HealthcareCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming Appointment',
                style: GoogleFonts.plusJakartaSans(
                  color: HealthcareColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const StatusChip(type: StatusType.confirmed, text: 'Confirmed'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: HealthcareColors.softCyan,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person, color: HealthcareColors.primaryTeal),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. Sarah Williams',
                    style: GoogleFonts.plusJakartaSans(
                      color: HealthcareColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cardiologist',
                    style: GoogleFonts.plusJakartaSans(
                      color: HealthcareColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: HealthcareColors.bgLightGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: HealthcareColors.primaryTeal),
                const SizedBox(width: 8),
                Text(
                  'Today, 10:00 AM',
                  style: GoogleFonts.plusJakartaSans(
                    color: HealthcareColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.videocam, size: 16, color: HealthcareColors.primaryTeal),
                const SizedBox(width: 8),
                Text(
                  'Online',
                  style: GoogleFonts.plusJakartaSans(
                    color: HealthcareColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  text: 'Reschedule',
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  text: 'Join Call',
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What do you need?',
          style: GoogleFonts.plusJakartaSans(
            color: HealthcareColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionItem(Icons.video_call, 'Online\nConsult', HealthcareColors.primaryTeal),
            _buildActionItem(Icons.local_hospital, 'Clinic\nVisit', HealthcareColors.primaryBlue),
            _buildActionItem(Icons.home, 'Home\nVisit', const Color(0xFFDD6B20)),
            _buildActionItem(Icons.directions_car, 'Pick up/\nDrop off', const Color(0xFF38A169)),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            color: HealthcareColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTopDoctors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Top Doctors',
              style: GoogleFonts.plusJakartaSans(
                color: HealthcareColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'See All',
              style: GoogleFonts.plusJakartaSans(
                color: HealthcareColors.primaryTeal,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return HealthcareCard(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: 140,
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: HealthcareColors.softCyan,
                        child: Icon(Icons.person, color: HealthcareColors.primaryTeal),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Dr. Smith',
                        style: GoogleFonts.plusJakartaSans(
                          color: HealthcareColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'General',
                        style: GoogleFonts.plusJakartaSans(
                          color: HealthcareColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '4.8',
                            style: GoogleFonts.plusJakartaSans(
                              color: HealthcareColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
