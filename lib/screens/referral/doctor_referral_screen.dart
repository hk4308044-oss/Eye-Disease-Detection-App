import 'package:flutter/material.dart';

class DoctorReferralScreen extends StatefulWidget {
  const DoctorReferralScreen({super.key});

  @override
  State<DoctorReferralScreen> createState() => _DoctorReferralScreenState();
}

class _DoctorReferralScreenState extends State<DoctorReferralScreen> {
  bool _isLoading = true;
  bool _hasLocationPermission = false;

  @override
  void initState() {
    super.initState();
    _checkLocationAndFetchDoctors();
  }

  Future<void> _checkLocationAndFetchDoctors() async {
    // Simulate checking for location permission
    await Future.delayed(const Duration(seconds: 1));
    
    // Simulate permission denied or no real data architecture
    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasLocationPermission = false; // Mocking unavailable state
      });
    }
  }

  Future<void> _requestPermission() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isLoading = false;
        // Even if granted, we don't have a real doctor DB, so we show empty state
        _hasLocationPermission = true; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Find a Specialist"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_hasLocationPermission
              ? _buildPermissionState(theme, textTheme)
              : _buildEmptyState(theme, textTheme),
    );
  }

  Widget _buildPermissionState(ThemeData theme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 24),
          Text("Location Required", style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(
            "To find eye care specialists near you, we need access to your device's location.",
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _requestPermission,
              child: const Text("Enable Location"),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_outlined, size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 24),
          Text("No Specialists Found", style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(
            "We couldn't find any registered specialists in your immediate area at this time. Our database is continuously expanding.",
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Go Back"),
            ),
          )
        ],
      ),
    );
  }
}
