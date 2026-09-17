import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../models/specialist_models.dart';
import '../../theme/app_theme.dart';
import 'appointment_confirmation_screen.dart';

class AppointmentBookingScreen extends StatefulWidget {
  final DoctorModel doctor;
  const AppointmentBookingScreen({super.key, required this.doctor});

  @override
  State<AppointmentBookingScreen> createState() => _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  int _step = 0;
  String _consultationType = 'Clinic Visit';
  DateTime? _selectedDate;
  String? _selectedSlot;

  final List<String> _consultationTypes = ['Clinic Visit', 'Online Consultation'];

  List<DateTime> _getAvailableDates() {
    final today = DateTime.now();
    final dayMap = {'Mon': 1, 'Tue': 2, 'Wed': 3, 'Thu': 4, 'Fri': 5, 'Sat': 6, 'Sun': 7};
    final allowedWeekdays = widget.doctor.availableDays.map((d) => dayMap[d] ?? 0).toSet();
    return List.generate(30, (i) => today.add(Duration(days: i + 1)))
        .where((d) => allowedWeekdays.contains(d.weekday))
        .take(14)
        .toList();
  }

  String get _stepTitle {
    switch (_step) {
      case 0: return 'Select Consultation Type';
      case 1: return 'Select Date';
      case 2: return 'Select Time Slot';
      case 3: return 'Confirm Appointment';
      default: return '';
    }
  }

  bool get _canProceed {
    if (_step == 0) return true;
    if (_step == 1) return _selectedDate != null;
    if (_step == 2) return _selectedSlot != null;
    return true;
  }

  void _next() {
    if (_step < 3) {
      setState(() => _step++);
    } else {
      _confirmBooking();
    }
  }

  void _confirmBooking() {
    final appointment = AppointmentModel(
      id: 'apt_${DateTime.now().millisecondsSinceEpoch}',
      doctor: widget.doctor,
      dateTime: DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        int.parse(_selectedSlot!.split(':')[0]) + (_selectedSlot!.contains('PM') && !_selectedSlot!.startsWith('12') ? 12 : 0),
        0,
      ),
      consultationType: _consultationType,
      status: 'upcoming',
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AppointmentConfirmationScreen(appointment: appointment)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text('Book Appointment', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
        backgroundColor: AppTheme.bgLight,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryNavy, size: 20),
          onPressed: _step == 0 ? () => Navigator.pop(context) : () => setState(() => _step--),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(4, (i) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color: i <= _step ? AppTheme.primaryTeal : AppTheme.borderLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  )),
                ),
                const SizedBox(height: 12),
                Text('Step ${_step + 1} of 4 — $_stepTitle',
                    style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textLightSecondary)),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: _buildStepContent(theme),
                ),
              ),
            ),
          ),

          // Next/Confirm button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _canProceed ? _next : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.borderLight,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  _step < 3 ? 'Continue' : 'Confirm Appointment',
                  style: theme.textTheme.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(ThemeData theme) {
    switch (_step) {
      case 0: return _buildStep0(theme);
      case 1: return _buildStep1(theme);
      case 2: return _buildStep2(theme);
      case 3: return _buildStep3(theme);
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildStep0(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _consultationTypes.map((type) {
        final isSelected = _consultationType == type;
        final isOnline = type == 'Online Consultation';
        final available = !isOnline || widget.doctor.offersOnlineConsultation;
        return GestureDetector(
          onTap: available ? () => setState(() => _consultationType = type) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppTheme.primaryTeal : AppTheme.borderLight,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: AppTheme.subtleShadowLight,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.lightTeal : AppTheme.bgSecondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isOnline ? Icons.videocam_outlined : CupertinoIcons.building_2_fill,
                    color: isSelected ? AppTheme.primaryTeal : AppTheme.textLightDisabled,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(type, style: theme.textTheme.titleSmall?.copyWith(color: available ? AppTheme.primaryNavy : AppTheme.textLightDisabled, fontWeight: FontWeight.bold)),
                      Text(
                        isOnline ? (available ? 'Video consultation from home' : 'Not offered by this doctor') : 'In-person at clinic',
                        style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textLightSecondary),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: AppTheme.primaryTeal),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStep1(ThemeData theme) {
    final dates = _getAvailableDates();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4),
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final isSelected = _selectedDate != null && DateUtils.isSameDay(_selectedDate!, date);
        return GestureDetector(
          onTap: () => setState(() => _selectedDate = date),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryTeal : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? AppTheme.primaryTeal : AppTheme.borderLight),
              boxShadow: AppTheme.subtleShadowLight,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(DateFormat('EEE').format(date), style: theme.textTheme.labelSmall?.copyWith(color: isSelected ? Colors.white.withValues(alpha: 0.8) : AppTheme.textLightSecondary)),
                const SizedBox(height: 4),
                Text(DateFormat('d').format(date), style: theme.textTheme.titleMedium?.copyWith(color: isSelected ? Colors.white : AppTheme.primaryNavy, fontWeight: FontWeight.bold)),
                Text(DateFormat('MMM').format(date), style: theme.textTheme.labelSmall?.copyWith(color: isSelected ? Colors.white.withValues(alpha: 0.8) : AppTheme.textLightSecondary)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep2(ThemeData theme) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: widget.doctor.availableSlots.map((slot) {
        final isSelected = _selectedSlot == slot;
        return GestureDetector(
          onTap: () => setState(() => _selectedSlot = slot),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryTeal : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? AppTheme.primaryTeal : AppTheme.borderLight),
              boxShadow: AppTheme.subtleShadowLight,
            ),
            child: Text(slot, style: theme.textTheme.labelLarge?.copyWith(
              color: isSelected ? Colors.white : AppTheme.primaryNavy,
              fontWeight: FontWeight.bold,
            )),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStep3(ThemeData theme) {
    return Container(
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
          Text('Appointment Summary', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
          const Divider(height: 24, color: AppTheme.borderLight),
          _buildConfirmRow(theme, 'Doctor', widget.doctor.name),
          _buildConfirmRow(theme, 'Specialty', widget.doctor.specialty),
          _buildConfirmRow(theme, 'Date', _selectedDate != null ? DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate!) : '—'),
          _buildConfirmRow(theme, 'Time', _selectedSlot ?? '—'),
          _buildConfirmRow(theme, 'Clinic', widget.doctor.clinic),
          _buildConfirmRow(theme, 'Address', widget.doctor.address),
          _buildConfirmRow(theme, 'Type', _consultationType),
          _buildConfirmRow(theme, 'Fee', 'PKR ${widget.doctor.consultationFee.toStringAsFixed(0)}'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.bgLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppTheme.textLightDisabled),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  'Please arrive 10 minutes early. Bring your AI screening report and any previous prescription.',
                  style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textLightSecondary, height: 1.5),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textLightSecondary))),
          Expanded(child: Text(value, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.primaryNavy, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
