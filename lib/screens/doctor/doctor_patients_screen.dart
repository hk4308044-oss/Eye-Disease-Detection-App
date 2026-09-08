import 'package:flutter/material.dart';
import '../../models/patient_record.dart';
import '../../services/doctor_service.dart';
import '../../theme/app_theme.dart';
import 'doctor_patient_detail_screen.dart';

class DoctorPatientsScreen extends StatefulWidget {
  /// If provided, immediately open this patient's detail on init
  final String? initialPatientId;

  const DoctorPatientsScreen({super.key, this.initialPatientId});

  @override
  State<DoctorPatientsScreen> createState() => _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends State<DoctorPatientsScreen> {
  final DoctorService _service = DoctorService();
  List<PatientRecord> _patients = [];
  List<PatientRecord> _filtered = [];
  bool _isLoading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() => _isLoading = true);
    try {
      final patients = await _service.getMyPatients();
      if (mounted) {
        setState(() {
          _patients = patients;
          _filtered = patients;
          _isLoading = false;
        });

        // Deep-link: immediately open a specific patient
        if (widget.initialPatientId != null) {
          final match = patients
              .where((p) => p.uid == widget.initialPatientId)
              .toList();
          if (match.isNotEmpty && mounted) {
            _openPatient(match.first);
          }
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearch(String query) {
    setState(() {
      _search = query;
      if (query.isEmpty) {
        _filtered = _patients;
      } else {
        _filtered = _patients
            .where((p) =>
                p.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _openPatient(PatientRecord patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorPatientDetailScreen(patient: patient),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: TextField(
            onChanged: _onSearch,
            decoration: InputDecoration(
              hintText: 'Search patients...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.textLightSecondary, size: 20),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        _onSearch('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: true,
              fillColor: const Color(0xFFF4F6F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const Divider(height: 1),

        // Content
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryTeal))
              : _filtered.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadPatients,
                      color: AppTheme.primaryTeal,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: _filtered.length,
                        itemBuilder: (context, i) =>
                            _buildPatientCard(_filtered[i]),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildPatientCard(PatientRecord patient) {
    return GestureDetector(
      onTap: () => _openPatient(patient),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderLight, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryNavy.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            _buildAvatar(patient),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryNavy,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${patient.age} yrs • ${patient.gender}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textLightSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  if (patient.symptoms.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 3,
                      children: patient.symptoms
                          .take(2)
                          .map((s) => _symptomChip(s))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            // Screenings count badge
            if (patient.screenings.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${patient.screenings.length} scans',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryTeal,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            const Icon(Icons.chevron_right, color: AppTheme.textLightDisabled, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(PatientRecord patient) {
    if (patient.profileImageUrl != null && patient.profileImageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(patient.profileImageUrl!),
      );
    }
    final initials =
        patient.name.isNotEmpty ? patient.name[0].toUpperCase() : 'P';
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppTheme.primaryNavy.withOpacity(0.08),
      child: Text(
        initials,
        style: const TextStyle(
          color: AppTheme.primaryNavy,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Widget _symptomChip(String symptom) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        symptom,
        style: const TextStyle(
          fontSize: 10,
          color: AppTheme.textLightSecondary,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_search.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 48, color: AppTheme.textLightDisabled),
            const SizedBox(height: 12),
            Text(
              'No results for "$_search"',
              style: const TextStyle(
                  color: AppTheme.textLightSecondary, fontFamily: 'Inter'),
            ),
          ],
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people_outline,
                size: 40, color: AppTheme.primaryTeal),
          ),
          const SizedBox(height: 16),
          const Text(
            'No patients yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryNavy,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Patients who book appointments with you\nwill appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textLightSecondary,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
