import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../theme/app_theme.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.bgLight, // #F4F6F8
      appBar: AppBar(
        title: Text(
          "Learn About Eye Health",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryNavy,
          ),
        ),
        backgroundColor: AppTheme.bgLight,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryNavy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        children: [
          // Intro text
          Text(
            "Knowledge is the first step to prevention.",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textLightSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          
          _buildDiseaseCard(
            context: context,
            title: "Cataract",
            icon: CupertinoIcons.eye_slash,
            description: "A clouding of the normally clear lens of the eye, often developing slowly over years.",
            symptoms: ["Blurry or dim vision", "Increasing difficulty with vision at night", "Sensitivity to light and glare", "Seeing 'halos' around lights"],
            riskFactors: ["Increasing age", "Diabetes", "Excessive exposure to sunlight", "Smoking"],
            prevention: ["Wear sunglasses blocking UV rays", "Manage other health problems", "Quit smoking"],
            whenToSeeDoc: "If vision changes begin to interfere with your daily activities, such as reading or driving.",
          ),

          _buildDiseaseCard(
            context: context,
            title: "Glaucoma",
            icon: CupertinoIcons.circle_grid_hex_fill,
            description: "A group of eye conditions that damage the optic nerve, often linked to abnormally high pressure in your eye.",
            symptoms: ["Often asymptomatic in early stages", "Patchy blind spots in your peripheral vision", "Tunnel vision in advanced stages"],
            riskFactors: ["High internal eye pressure (intraocular pressure)", "Age over 60", "Family history of glaucoma"],
            prevention: ["Get regular dilated eye examinations", "Know your family's eye health history", "Exercise safely"],
            whenToSeeDoc: "Immediately if you experience severe headache, eye pain, nausea, blurred vision, or halos around lights (signs of acute angle-closure glaucoma).",
          ),

          _buildDiseaseCard(
            context: context,
            title: "Diabetic Retinopathy",
            icon: CupertinoIcons.drop,
            description: "A diabetes complication that affects eyes. It's caused by damage to the blood vessels of the light-sensitive tissue at the back of the eye (retina).",
            symptoms: ["Spots or dark strings floating in vision (floaters)", "Blurred or fluctuating vision", "Impaired color vision", "Dark or empty areas in vision"],
            riskFactors: ["Poor control of blood sugar levels", "High blood pressure", "High cholesterol", "Pregnancy"],
            prevention: ["Carefully manage your diabetes", "Monitor blood sugar and blood pressure", "Take annual eye exams"],
            whenToSeeDoc: "If you have diabetes, see your eye doctor for a yearly dilated eye exam. Seek immediate care for sudden vision changes.",
          ),

          _buildDiseaseCard(
            context: context,
            title: "Conjunctivitis",
            icon: CupertinoIcons.eye,
            description: "Also known as pink eye, it's an inflammation or infection of the transparent membrane that lines your eyelid and covers the white part of your eyeball.",
            symptoms: ["Redness in one or both eyes", "Itchiness or a gritty feeling", "A discharge that forms a crust during the night", "Tearing"],
            riskFactors: ["Exposure to something you're allergic to", "Exposure to someone infected", "Using contact lenses improperly"],
            prevention: ["Don't touch your eyes with your hands", "Wash your hands often", "Don't share towels or washcloths"],
            whenToSeeDoc: "If accompanied by pain in the eye, feeling that something is stuck in your eye, or blurred vision that doesn't clear when you blink.",
          ),

          _buildDiseaseCard(
            context: context,
            title: "Healthy Eye Care",
            icon: CupertinoIcons.heart,
            description: "Daily practices and habits to maintain optimal vision and protect against preventable eye strain and damage.",
            symptoms: ["Digital eye strain", "Dry or irritated eyes after long work periods", "Mild fatigue"],
            riskFactors: ["Prolonged screen time", "Poor diet lacking essential nutrients", "Inadequate sleep", "UV exposure"],
            prevention: ["Follow the 20-20-20 rule: Every 20 minutes, look 20 feet away for 20 seconds", "Eat a balanced diet rich in Omega-3s and lutein", "Stay hydrated"],
            whenToSeeDoc: "Schedule routine comprehensive eye exams every 1-2 years, even if your vision feels perfectly fine.",
          ),

          const SizedBox(height: 32),
          
          // Disclaimer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.bgSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(CupertinoIcons.shield_lefthalf_fill, color: AppTheme.primaryTeal, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "This information is provided for educational purposes only and is not intended to replace professional medical advice, diagnosis, or treatment.",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textLightSecondary,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildDiseaseCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String description,
    required List<String> symptoms,
    required List<String> riskFactors,
    required List<String> prevention,
    required String whenToSeeDoc,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.subtleShadowLight,
        border: Border.all(color: AppTheme.borderLight, width: 0.8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            title: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryNavy,
              ),
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryTeal, size: 24),
            ),
            iconColor: AppTheme.primaryTeal,
            collapsedIconColor: AppTheme.textLightDisabled,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0, top: 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: AppTheme.borderLight),
                    const SizedBox(height: 16),
                    
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryNavy,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildSubSection(theme, "Common Symptoms", symptoms),
                    const SizedBox(height: 20),
                    _buildSubSection(theme, "Risk Factors", riskFactors),
                    const SizedBox(height: 20),
                    _buildSubSection(theme, "Prevention & Care", prevention),
                    
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.bgLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(CupertinoIcons.exclamationmark_triangle, size: 16, color: AppTheme.primaryNavy),
                              const SizedBox(width: 8),
                              Text(
                                "When to seek care",
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryNavy,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            whenToSeeDoc,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.textLightSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubSection(ThemeData theme, String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textLightSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 6.0, right: 12.0),
                child: Icon(Icons.circle, size: 4, color: AppTheme.primaryTeal),
              ),
              Expanded(
                child: Text(
                  item,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textLightPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
