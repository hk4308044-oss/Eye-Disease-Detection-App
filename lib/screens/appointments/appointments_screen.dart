import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fyp_flutter/widgets/healthcare_components.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HealthcareColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: HealthcareColors.bgWhite,
        elevation: 0,
        title: Text(
          'Appointments',
          style: GoogleFonts.plusJakartaSans(
            color: HealthcareColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _buildTab('Upcoming', true),
                const SizedBox(width: 12),
                _buildTab('Past', false),
                const SizedBox(width: 12),
                _buildTab('Cancelled', false),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildLiveQueueBanner(),
          const SizedBox(height: 16),
          _buildAppointmentCard(
            status: StatusType.active,
            statusText: 'In Progress',
            doctorName: 'Dr. Sarah Williams',
            specialty: 'Cardiologist',
            time: 'Today, 10:00 AM',
            type: 'Online Consult',
            icon: Icons.videocam,
          ),
          const SizedBox(height: 16),
          _buildAppointmentCard(
            status: StatusType.pending,
            statusText: 'Waiting',
            doctorName: 'Dr. Emily Chen',
            specialty: 'Dermatologist',
            time: 'Tomorrow, 2:30 PM',
            type: 'Clinic Visit',
            icon: Icons.local_hospital,
          ),
          const SizedBox(height: 16),
          _buildAppointmentCard(
            status: StatusType.confirmed,
            statusText: 'Confirmed',
            doctorName: 'Dr. James Smith',
            specialty: 'General Physician',
            time: 'Oct 24, 9:00 AM',
            type: 'Home Visit',
            icon: Icons.home,
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, bool isSelected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? HealthcareColors.primaryTeal : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.BorderSide(color: HealthcareColors.textSecondary.withOpacity(0.3)),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            color: isSelected ? Colors.white : HealthcareColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildLiveQueueBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HealthcareColors.softCyan,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HealthcareColors.primaryTeal.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: HealthcareColors.bgWhite,
              shape: BoxShape.circle,
            ),
            child: const Text(
              '3',
              style: TextStyle(
                color: HealthcareColors.primaryTeal,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Queue Number',
                  style: GoogleFonts.plusJakartaSans(
                    color: HealthcareColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Est. wait time: 15 mins',
                  style: GoogleFonts.plusJakartaSans(
                    color: HealthcareColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard({
    required StatusType status,
    required String statusText,
    required String doctorName,
    required String specialty,
    required String time,
    required String type,
    required IconData icon,
  }) {
    return HealthcareCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: HealthcareColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    type,
                    style: GoogleFonts.plusJakartaSans(
                      color: HealthcareColors.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              StatusChip(type: status, text: statusText),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: HealthcareColors.softCyan,
                child: Icon(Icons.person, color: HealthcareColors.primaryTeal),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctorName,
                    style: GoogleFonts.plusJakartaSans(
                      color: HealthcareColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    specialty,
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
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: HealthcareColors.primaryTeal),
              const SizedBox(width: 8),
              Text(
                time,
                style: GoogleFonts.plusJakartaSans(
                  color: HealthcareColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
