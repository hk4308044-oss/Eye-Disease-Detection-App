import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accessibility"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Icon(Icons.accessibility_new, size: 64, color: Colors.blue),
          const SizedBox(height: 24),
          Text(
            "Visual Preferences",
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            "Customize your viewing experience to make the application easier to read and navigate.",
          ),
          const SizedBox(height: 32),
          
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Text Scaling", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Current Scale: ${appState.textScaleFactor.toStringAsFixed(1)}x"),
                  Slider(
                    value: appState.textScaleFactor,
                    min: 1.0,
                    max: 2.0,
                    divisions: 10,
                    label: "${appState.textScaleFactor.toStringAsFixed(1)}x",
                    onChanged: (value) => appState.setTextScaleFactor(value),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SwitchListTile(
              title: Text("High Contrast Mode", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              subtitle: const Text("Increase contrast between text and backgrounds."),
              value: appState.highContrast,
              onChanged: (value) => appState.setHighContrast(value),
            ),
          ),
          
          const SizedBox(height: 32),
          
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SwitchListTile(
              title: Text("Screen Reader Optimized", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              subtitle: const Text("Enables additional vocal cues for navigation (Simulated)."),
              value: false, // Just a visual mock for the settings
              onChanged: (value) {},
            ),
          ),
        ],
      ),
    );
  }
}
