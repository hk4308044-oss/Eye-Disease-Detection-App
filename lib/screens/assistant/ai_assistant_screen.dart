import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/eye_screening_result.dart';
import '../../theme/app_theme.dart';
import '../specialist/find_specialist_screen.dart';

// ─────────────────────────────────────────────
// Data model for a chat message
// ─────────────────────────────────────────────
class ChatMessage {
  final bool isAi;
  final String text;
  final List<String>? bullets;
  final String? ctaLabel;
  final VoidCallback? ctaAction;
  final bool isUrgent;

  const ChatMessage({
    required this.isAi,
    required this.text,
    this.bullets,
    this.ctaLabel,
    this.ctaAction,
    this.isUrgent = false,
  });
}

// ─────────────────────────────────────────────
// Quick action definition
// ─────────────────────────────────────────────
class _QuickAction {
  final String label;
  final IconData icon;
  final String prompt;
  const _QuickAction(this.label, this.icon, this.prompt);
}

// ─────────────────────────────────────────────
// AI ASSISTANT SCREEN
// ─────────────────────────────────────────────
class AiAssistantScreen extends StatefulWidget {
  /// Optional screening result for contextual entry from result screen
  final EyeScreeningResult? screeningContext;

  const AiAssistantScreen({super.key, this.screeningContext});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen>
    with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isThinking = false;
  bool _showQuickActions = true;
  String _userName = '';
  EyeScreeningResult? _latestScreening;

  late AnimationController _pulseController;

  static const List<_QuickAction> _quickActions = [
    _QuickAction("Explain My Last Screening", CupertinoIcons.doc_text_search, "Can you explain my latest AI screening result?"),
    _QuickAction("What Does My Result Mean?", CupertinoIcons.question_circle, "What does my AI eye screening result mean?"),
    _QuickAction("How Can I Protect My Eyes?", CupertinoIcons.eye, "How can I protect my eyes and maintain good eye health?"),
    _QuickAction("Tell Me About My Symptoms", CupertinoIcons.waveform_path_ecg, "I have some eye symptoms I'd like to understand better."),
    _QuickAction("When to See a Specialist?", CupertinoIcons.person_badge_plus, "When should I see an eye specialist?"),
    _QuickAction("Prepare Doctor Questions", CupertinoIcons.list_bullet_indent, "Help me prepare questions to ask my eye doctor."),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadUserContext();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserContext() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _initChat();
      return;
    }
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        _userName = (userDoc.data()?['name'] as String?) ?? '';
      }
      final screenings = await FirebaseFirestore.instance
          .collection('users').doc(uid).collection('screenings')
          .orderBy('date', descending: true).limit(1).get();
      if (screenings.docs.isNotEmpty) {
        _latestScreening = EyeScreeningResult.fromFirestore(screenings.docs.first.data(), screenings.docs.first.id);
      }
    } catch (_) {}
    _initChat();
  }

  void _initChat() {
    if (!mounted) return;
    // If opened from screening result, use that as context
    if (widget.screeningContext != null) {
      _latestScreening = widget.screeningContext;
    }

    final greeting = _userName.isNotEmpty ? 'Hi, ${_userName.split(' ').first}!' : 'Hello!';
    setState(() {
      _messages.add(ChatMessage(
        isAi: true,
        text: '$greeting I\'m your AI Eye Health Companion. I can help you understand your eye health, explain screening results, and guide you on when to seek professional care.',
        bullets: null,
      ));
      // If there is a screening context, auto-send a contextual intro
      if (widget.screeningContext != null) {
        _showQuickActions = false;
        Future.delayed(const Duration(milliseconds: 400), () {
          _handleSend("Explain my latest AI screening result to me.");
        });
      }
    });
  }

  // ─────────────────────────────────────────────
  // Core response engine
  // ─────────────────────────────────────────────
  ChatMessage _generateResponse(String query) {
    final q = query.toLowerCase();

    // URGENT symptom detection
    if (_containsAny(q, ['sudden vision loss', 'sudden blindness', 'severe eye pain', 'chemical in eye', 'eye injury', 'can\'t see', 'cannot see', 'lost vision'])) {
      return ChatMessage(
        isAi: true,
        isUrgent: true,
        text: '⚠️ This sounds like an urgent eye emergency.',
        bullets: [
          'Seek immediate emergency medical care.',
          'Do not rub or touch the eye.',
          'If chemicals are involved, rinse with clean water for 15 minutes.',
          'Call emergency services or go to the nearest hospital immediately.',
        ],
        ctaLabel: null,
      );
    }

    // Screening result explanation
    if (_containsAny(q, ['screening result', 'latest result', 'explain my result', 'what does my result', 'ai result', 'explain screening'])) {
      if (_latestScreening != null) {
        final r = _latestScreening!;
        return ChatMessage(
          isAi: true,
          text: 'Here\'s an explanation of your AI screening result. Please remember: this is an AI analysis — not a confirmed medical diagnosis.',
          bullets: [
            '📋 Indication: ${r.observation}',
            '📊 AI Confidence: ${r.confidence.toStringAsFixed(1)}%',
            '🔶 Risk Level: ${_riskLabel(r.riskLevel)}',
            'The AI detected visual patterns consistent with ${r.observation}. This requires professional confirmation by a certified eye-care specialist.',
            'A confidence score of ${r.confidence.toStringAsFixed(0)}% means the AI model found strong pattern similarities — but this is not a diagnosis.',
          ],
          ctaLabel: 'Find an Eye Specialist',
          ctaAction: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => FindSpecialistScreen(screeningCategory: r.observation),
          )),
        );
      } else {
        return ChatMessage(
          isAi: true,
          text: 'I don\'t see a recent AI screening result linked to your account yet.',
          bullets: [
            'Complete an AI eye screening from the scan tab.',
            'Once done, I can explain your result in detail.',
          ],
        );
      }
    }

    // Cataract
    if (_containsAny(q, ['cataract', 'cloudy lens', 'cloudy vision', 'blurry lens'])) {
      return ChatMessage(
        isAi: true,
        text: 'Here\'s what you should know about cataracts:',
        bullets: [
          '🔍 What it is: A clouding of the normally clear lens of the eye.',
          '📝 Common symptoms: Blurry vision, faded colours, glare, halos around lights.',
          '⚠️ Risk factors: Age, diabetes, UV exposure, smoking.',
          '✅ Good news: Cataracts are treatable with surgery in advanced cases.',
          '👁️ Your AI screening indicates patterns consistent with a cataract — but only an ophthalmologist can confirm this.',
        ],
        ctaLabel: 'Find a Cataract Specialist',
        ctaAction: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => const FindSpecialistScreen(screeningCategory: 'Cataract'),
        )),
      );
    }

    // Glaucoma
    if (_containsAny(q, ['glaucoma', 'optic nerve', 'pressure in eye', 'eye pressure', 'peripheral vision'])) {
      return ChatMessage(
        isAi: true,
        text: 'Glaucoma is a serious but manageable condition:',
        bullets: [
          '🔍 What it is: Damage to the optic nerve, often due to high eye pressure.',
          '📝 It\'s often called the "silent thief" because it has no symptoms early on.',
          '⚠️ Risk factors: Age over 60, family history, high eye pressure, diabetes.',
          '✅ Early detection is crucial — treatment can slow or stop vision loss.',
          '🩺 AI screening can detect early visual pattern changes, but a specialist test (tonometry, visual fields) is needed to confirm.',
        ],
        ctaLabel: 'Find a Glaucoma Specialist',
        ctaAction: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => const FindSpecialistScreen(screeningCategory: 'Glaucoma'),
        )),
      );
    }

    // Diabetic retinopathy
    if (_containsAny(q, ['diabetic retinopathy', 'retina', 'diabetes eye', 'diabetic eye'])) {
      return ChatMessage(
        isAi: true,
        text: 'Diabetic Retinopathy explained:',
        bullets: [
          '🔍 What it is: Damage to retinal blood vessels caused by diabetes.',
          '📝 Symptoms: Floaters, blurred vision, difficulty seeing at night, dark patches.',
          '⚠️ Risk factors: Poorly controlled blood sugar, long-term diabetes, high BP.',
          '✅ Managing blood sugar levels is the most effective prevention.',
          '🩺 Annual eye exams are essential for all people with diabetes.',
        ],
        ctaLabel: 'Find a Retina Specialist',
        ctaAction: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => const FindSpecialistScreen(screeningCategory: 'Diabetic Retinopathy'),
        )),
      );
    }

    // Conjunctivitis
    if (_containsAny(q, ['conjunctivitis', 'pink eye', 'red eye', 'eye redness', 'itchy eye', 'discharge'])) {
      return ChatMessage(
        isAi: true,
        text: 'Eye redness can have several causes:',
        bullets: [
          '🔍 Conjunctivitis (Pink Eye): Inflammation of the clear membrane over the white of the eye.',
          '📝 Causes: Viral, bacterial, or allergic — they look similar but are treated differently.',
          '✅ Allergic: Antihistamines & avoiding triggers.',
          '✅ Bacterial: Usually needs antibiotic eye drops (prescribed by a doctor).',
          '✅ Viral: Generally resolves on its own in 1–2 weeks.',
          '⚠️ See a doctor if symptoms worsen or don\'t improve within a few days.',
        ],
      );
    }

    // Protect eyes / prevention
    if (_containsAny(q, ['protect', 'prevent', 'healthy eye', 'maintain', 'eye care', 'eye health'])) {
      return ChatMessage(
        isAi: true,
        text: 'Here are evidence-based ways to protect your eye health:',
        bullets: [
          '🕶️ Wear UV-blocking sunglasses outdoors.',
          '📱 Follow the 20-20-20 rule: Every 20 min, look 20 feet away for 20 seconds.',
          '🥦 Eat foods rich in lutein, zeaxanthin, omega-3s (leafy greens, fish).',
          '🚭 Don\'t smoke — it significantly increases risk of eye diseases.',
          '💧 Stay hydrated and use artificial tears if your eyes feel dry.',
          '👁️ Schedule regular comprehensive eye exams every 1–2 years.',
        ],
      );
    }

    // Symptoms - blurry vision
    if (_containsAny(q, ['blurry', 'blurred', 'fuzzy', 'not clear', 'can\'t focus'])) {
      return ChatMessage(
        isAi: true,
        text: 'Blurred vision can have many causes — only a professional exam can identify the specific reason.',
        bullets: [
          '👓 Refractive errors (myopia, hyperopia, astigmatism) — most common, correctable with glasses.',
          '💊 Medication side effects.',
          '💧 Dry eye syndrome.',
          '⚠️ Eye diseases like cataracts, glaucoma, or diabetic retinopathy.',
          '🩺 If blurring is sudden, severe, or in only one eye — seek care promptly.',
        ],
        ctaLabel: 'Find an Eye Specialist',
        ctaAction: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => const FindSpecialistScreen(),
        )),
      );
    }

    // When to see specialist
    if (_containsAny(q, ['when to see', 'see a doctor', 'see a specialist', 'visit doctor', 'ophthalmologist', 'optometrist', 'consult'])) {
      return ChatMessage(
        isAi: true,
        text: 'Knowing when to seek professional eye care is important:',
        bullets: [
          '🔴 Immediately: Sudden vision loss, severe eye pain, sudden floaters/flashes, chemical exposure.',
          '🟠 Within a week: Persistent redness, new discharge, blurring not helped by blinking.',
          '🟡 Within a month: Gradual vision changes, difficulty with night vision.',
          '🟢 Routine: Every 1–2 years for comprehensive eye exams even if asymptomatic.',
          '📋 Any AI screening result flagging a potential abnormality warrants professional confirmation.',
        ],
        ctaLabel: 'Find an Eye Specialist',
        ctaAction: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => const FindSpecialistScreen(),
        )),
      );
    }

    // Prepare doctor questions
    if (_containsAny(q, ['prepare questions', 'doctor questions', 'what to ask', 'questions for my doctor'])) {
      return ChatMessage(
        isAi: true,
        text: 'Here are helpful questions to prepare before seeing your eye specialist:',
        bullets: [
          '"Is my vision within normal range for my age?"',
          '"What is the significance of my AI screening result?"',
          '"Do I need further diagnostic tests?"',
          '"What are my treatment options if there is an issue?"',
          '"How often should I have my eyes examined?"',
          '"Should I be concerned about my family history of eye disease?"',
          '"What lifestyle changes can help protect my vision?"',
        ],
      );
    }

    // Confidence score
    if (_containsAny(q, ['confidence score', 'confidence', 'what does 87%', 'what does the percentage'])) {
      return ChatMessage(
        isAi: true,
        text: 'The AI confidence score explained:',
        bullets: [
          '📊 The confidence score shows how closely the AI matched your eye image to known visual patterns.',
          '✅ Higher confidence means the AI model found stronger pattern similarity.',
          '⚠️ A high confidence score does NOT mean a confirmed diagnosis.',
          '🩺 The result always requires confirmation by a qualified eye-care professional.',
          '💡 Think of it as: "The AI is fairly certain it saw this pattern" — not "You definitely have this condition."',
        ],
      );
    }

    // 20-20-20 / eye strain / screen time
    if (_containsAny(q, ['eye strain', 'screen time', 'tired eyes', '20-20-20', 'digital eye'])) {
      return ChatMessage(
        isAi: true,
        text: 'Managing digital eye strain:',
        bullets: [
          '🕑 20-20-20 Rule: Every 20 minutes, look 20 feet away for at least 20 seconds.',
          '💻 Position your screen at arm\'s length and slightly below eye level.',
          '💡 Match screen brightness to your room lighting.',
          '💧 Blink consciously — we blink less when on screens.',
          '🌙 Enable night mode / blue light filter after sunset.',
          '⏸️ Take a 5–10 minute break every hour.',
        ],
      );
    }

    // Default fallback
    return ChatMessage(
      isAi: true,
      text: 'That\'s a thoughtful question about your eye health. While I can provide general eye-health education, I\'m not able to provide a personal medical assessment.',
      bullets: [
        'Could you describe your question in more detail?',
        'For example: specific symptoms, conditions, or something from your screening result?',
        'For any concerning symptoms, please consult a certified eye-care professional.',
      ],
      ctaLabel: 'Find an Eye Specialist',
      ctaAction: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => const FindSpecialistScreen(),
      )),
    );
  }

  bool _containsAny(String text, List<String> keywords) =>
      keywords.any((k) => text.contains(k));

  String _riskLabel(RiskLevel level) {
    switch (level) {
      case RiskLevel.low: return 'Mild / Low Risk';
      case RiskLevel.attention: return 'Moderate Risk';
      case RiskLevel.high: return 'Severe / High Risk';
    }
  }

  // ─────────────────────────────────────────────
  // Send / typing flow
  // ─────────────────────────────────────────────
  void _handleSend(String text) {
    if (text.trim().isEmpty) return;
    _inputController.clear();
    setState(() {
      _showQuickActions = false;
      _messages.add(ChatMessage(isAi: false, text: text.trim()));
      _isThinking = true;
    });
    _scrollToBottom();

    // Simulate AI processing time
    final delay = 800 + (text.length * 8).clamp(0, 1600);
    Future.delayed(Duration(milliseconds: delay), () {
      if (!mounted) return;
      final response = _generateResponse(text);
      setState(() {
        _isThinking = false;
        _messages.add(response);
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: _buildAppBar(theme),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              itemCount: _messages.length + (_isThinking ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _messages.length) return _buildThinkingIndicator(theme);
                return _buildMessage(theme, _messages[i]);
              },
            ),
          ),
          if (_showQuickActions && _messages.length <= 1)
            _buildQuickActions(theme),
          _buildDisclaimer(theme),
          _buildInputBar(theme),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryNavy, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) => Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.lightTeal,
                border: Border.all(
                  color: AppTheme.primaryTeal.withOpacity(0.2 + 0.3 * _pulseController.value),
                  width: 1.5,
                ),
              ),
              child: const Center(child: Icon(CupertinoIcons.eye_solid, color: AppTheme.primaryTeal, size: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI Eye Assistant', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
              Row(
                children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.statusGreen, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text('Online · Eye Health Companion', style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.textLightSecondary)),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(CupertinoIcons.arrow_counterclockwise, color: AppTheme.primaryNavy, size: 20),
          tooltip: 'New Chat',
          onPressed: () => setState(() {
            _messages.clear();
            _showQuickActions = true;
            _initChat();
          }),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Message bubble
  // ─────────────────────────────────────────────
  Widget _buildMessage(ThemeData theme, ChatMessage msg) {
    if (msg.isAi) return _buildAiMessage(theme, msg);
    return _buildUserMessage(theme, msg);
  }

  Widget _buildUserMessage(ThemeData theme, ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: const BoxDecoration(
                color: AppTheme.primaryTeal,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(msg.text, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, height: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiMessage(ThemeData theme, ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 48),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(top: 2, right: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: msg.isUrgent ? AppTheme.statusRed.withOpacity(0.1) : AppTheme.lightTeal,
              border: Border.all(color: msg.isUrgent ? AppTheme.statusRed.withOpacity(0.3) : AppTheme.primaryTeal.withOpacity(0.3)),
            ),
            child: Icon(
              msg.isUrgent ? Icons.warning_rounded : CupertinoIcons.eye_solid,
              color: msg.isUrgent ? AppTheme.statusRed : AppTheme.primaryTeal,
              size: 16,
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main bubble
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: msg.isUrgent ? const Color(0xFFFEF2F2) : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    border: Border.all(
                      color: msg.isUrgent ? AppTheme.statusRed.withOpacity(0.2) : AppTheme.borderLight,
                      width: 0.8,
                    ),
                    boxShadow: AppTheme.subtleShadowLight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(msg.text, style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.primaryNavy, height: 1.55, fontWeight: FontWeight.w500)),
                      if (msg.bullets != null && msg.bullets!.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        ...msg.bullets!.map((b) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 6, right: 10),
                                child: Icon(Icons.circle, size: 4, color: AppTheme.primaryTeal),
                              ),
                              Expanded(
                                child: Text(b, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textLightPrimary, height: 1.5)),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ],
                  ),
                ),
                // CTA button
                if (msg.ctaLabel != null && msg.ctaAction != null) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    child: OutlinedButton.icon(
                      onPressed: msg.ctaAction,
                      icon: const Icon(Icons.search_rounded, size: 16),
                      label: Text(msg.ctaLabel!),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryTeal,
                        side: const BorderSide(color: AppTheme.primaryTeal),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        textStyle: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThinkingIndicator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 48),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            margin: const EdgeInsets.only(right: 10),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.lightTeal),
            child: const Icon(CupertinoIcons.eye_solid, color: AppTheme.primaryTeal, size: 16),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4), topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18),
              ),
              border: Border.all(color: AppTheme.borderLight, width: 0.8),
              boxShadow: AppTheme.subtleShadowLight,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('AI Assistant is thinking', style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textLightSecondary)),
                const SizedBox(width: 8),
                SizedBox(width: 24, height: 12, child: LinearProgressIndicator(color: AppTheme.primaryTeal, backgroundColor: AppTheme.borderLight, borderRadius: BorderRadius.circular(4))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Quick Actions
  // ─────────────────────────────────────────────
  Widget _buildQuickActions(ThemeData theme) {
    return Container(
      color: AppTheme.bgLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
            child: Text('Quick questions', style: theme.textTheme.labelMedium?.copyWith(color: AppTheme.textLightSecondary, fontWeight: FontWeight.w600)),
          ),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _quickActions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final action = _quickActions[i];
                return GestureDetector(
                  onTap: () => _handleSend(action.prompt),
                  child: Container(
                    width: 140,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderLight),
                      boxShadow: AppTheme.subtleShadowLight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(action.icon, size: 18, color: AppTheme.primaryTeal),
                        const Spacer(),
                        Text(action.label, style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.primaryNavy, fontWeight: FontWeight.w600, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Disclaimer
  // ─────────────────────────────────────────────
  Widget _buildDisclaimer(ThemeData theme) {
    return Container(
      color: AppTheme.bgLight,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Text(
        'AI guidance is for informational purposes and does not replace professional medical advice.',
        style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.textLightDisabled, height: 1.3),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Input Bar
  // ─────────────────────────────────────────────
  Widget _buildInputBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.bgLight,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: TextField(
                  controller: _inputController,
                  minLines: 1,
                  maxLines: 4,
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.primaryNavy),
                  decoration: InputDecoration(
                    hintText: 'Ask about your eye health...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textLightDisabled),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  onSubmitted: _handleSend,
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _handleSend(_inputController.text),
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryTeal,
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.arrow_up, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
