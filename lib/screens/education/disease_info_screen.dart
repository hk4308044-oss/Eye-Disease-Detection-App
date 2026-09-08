import 'package:flutter/material.dart';

class DiseaseInfoScreen extends StatelessWidget {
  final String condition;

  const DiseaseInfoScreen({super.key, required this.condition});

  @override
  Widget build(BuildContext context) {
    // Generate dummy info based on the condition name
    String title = condition.replaceAll('[DEMO]', '').trim();
    if (title.contains("Possible")) {
      title = title.replaceAll('Possible', '').trim();
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Educational Info"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "About $title",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[900],
                  ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              "What is it?",
              "$title is an eye condition that can affect your vision. Early detection and treatment are crucial to preventing severe vision loss.",
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              "Common Symptoms",
              "• Blurry or cloudy vision\n• Difficulty seeing at night\n• Sensitivity to light and glare\n• Seeing 'halos' around lights",
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              "Risk Factors",
              "• Increasing age\n• Diabetes\n• Excessive exposure to sunlight\n• Smoking\n• High blood pressure",
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              "When to seek evaluation",
              "If you experience sudden changes in your vision, such as sudden blurriness, flashes of light, or an increase in floaters, you should consult an eye care professional immediately.",
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      "This information is for educational purposes and should not be used as medical advice.",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
