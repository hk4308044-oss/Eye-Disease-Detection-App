import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../models/specialist_models.dart';
import '../../theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'my_appointments_screen.dart';

class AppointmentConfirmationScreen extends StatelessWidget {
  final AppointmentModel appointment;
  const AppointmentConfirmationScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final doc = appointment.doctor;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.statusGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.statusGreen.withOpacity(0.3), width: 2),
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppTheme.statusGreen, size: 48),
              ),
              const SizedBox(height: 20),

              Text('Appointment Confirmed!', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
              const SizedBox(height: 8),
              Text(
                'Your appointment has been booked successfully.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textLightSecondary),
              ),

              const SizedBox(height: 32),

              // Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderLight),
                  boxShadow: AppTheme.subtleShadowLight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor info
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.primaryNavy),
                          child: Center(child: Text(doc.avatarInitials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doc.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                            Text(doc.specialty, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.primaryTeal)),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 28, color: AppTheme.borderLight),
                    _detailRow(theme, CupertinoIcons.calendar, 'Date', DateFormat('EEEE, MMMM d, yyyy').format(appointment.dateTime)),
                    _detailRow(theme, CupertinoIcons.clock, 'Time', DateFormat('h:mm a').format(appointment.dateTime)),
                    _detailRow(theme, CupertinoIcons.building_2_fill, 'Location', '${doc.clinic}, ${doc.address}'),
                    _detailRow(theme, appointment.consultationType == 'Online Consultation' ? Icons.videocam_outlined : Icons.person_outlined, 'Type', appointment.consultationType),
                    _detailRow(theme, CupertinoIcons.money_dollar_circle, 'Fee', 'PKR ${doc.consultationFee.toStringAsFixed(0)}'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              _actionButton(
                context, theme,
                icon: CupertinoIcons.calendar_badge_plus,
                label: 'Add to Calendar',
                onTap: () async {
                  try {
                    final Event event = Event(
                      title: 'Appointment with ${doc.name}',
                      description: 'Consultation Type: ${appointment.consultationType}\nFee: PKR ${doc.consultationFee}',
                      location: '${doc.clinic}, ${doc.address}',
                      startDate: appointment.dateTime,
                      endDate: appointment.dateTime.add(const Duration(minutes: 30)),
                    );
                    
                    final success = await Add2Calendar.addEvent2Cal(event);
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment added to your calendar.')));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add to calendar.')));
                    }
                  }
                },
              ),
              const SizedBox(height: 12),
              _actionButton(
                context, theme,
                icon: Icons.directions_rounded,
                label: 'Get Directions',
                onTap: () async {
                  try {
                    final Uri uri = Uri.parse('geo:${doc.latitude},${doc.longitude}?q=${Uri.encodeComponent('${doc.clinic}, ${doc.address}')}');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      final Uri fallbackUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('${doc.clinic}, ${doc.address}')}');
                      if (await canLaunchUrl(fallbackUri)) {
                        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maps application is currently unavailable.')));
                        }
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to open directions.')));
                    }
                  }
                },
              ),
              const SizedBox(height: 12),
              _actionButton(
                context, theme,
                icon: Icons.call_outlined,
                label: 'Contact Clinic',
                onTap: () async {
                  try {
                    final Uri phoneUri = Uri.parse('tel:${doc.phone}');
                    final Uri emailUri = Uri.parse('mailto:${doc.email}');
                    
                    if (doc.phone.isNotEmpty && await canLaunchUrl(phoneUri)) {
                      await launchUrl(phoneUri);
                    } else if (doc.email.isNotEmpty && await canLaunchUrl(emailUri)) {
                      await launchUrl(emailUri);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Clinic contact information is currently unavailable.')));
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to open contact options.')));
                    }
                  }
                },
              ),

              const SizedBox(height: 24),

              // Primary CTA
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => MyAppointmentsScreen(newAppointment: appointment)),
                      (route) => route.isFirst,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('View My Appointments'),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryTeal),
          const SizedBox(width: 10),
          SizedBox(width: 72, child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textLightSecondary))),
          Expanded(child: Text(value, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.primaryNavy, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, ThemeData theme, {required IconData icon, required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: AppTheme.borderLight),
          foregroundColor: AppTheme.primaryNavy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
