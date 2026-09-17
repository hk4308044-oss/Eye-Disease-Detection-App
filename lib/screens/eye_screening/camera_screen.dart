import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import '../../theme/app_theme.dart';
import 'ai_image_preparation_screen.dart';

class CameraScreen extends StatefulWidget {
  final String category;
  const CameraScreen({super.key, required this.category});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with TickerProviderStateMixin {
  // ── Camera ──────────────────────────────────────────────────────────
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  String? _initError;

  // ── Image state ────────────────────────────────────────────────────
  String? _capturedImagePath;
  bool _isCapturing = false;

  // ── Quality indicators (simulated) ─────────────────────────────────
  double _lightingScore = 0.0;
  String _lightingLabel = 'Analyzing…';
  Color _lightingColor = Colors.white38;
  double _qualityScore = 0.0;
  String _qualityLabel = 'Checking…';
  Color _qualityColor = Colors.white38;
  bool _eyeDetected = false;

  // ── Animation controllers ──────────────────────────────────────────
  late AnimationController _pulseAnim;
  late AnimationController _scanLineAnim;
  late AnimationController _cornerGlowAnim;
  late AnimationController _captureFlash;
  late AnimationController _fadeInAnim;

  Timer? _qualityTimer;

  // ── Constants ──────────────────────────────────────────────────────
  static const _guideDiameter = 260.0;
  static const _bgDark = Color(0xFF050B18);

  @override
  void initState() {
    super.initState();

    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _scanLineAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _cornerGlowAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _captureFlash = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _fadeInAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _initializeCamera();
  }

  // ────────────────────────────────────────────────────────────────────
  // CAMERA INIT
  // ────────────────────────────────────────────────────────────────────
  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        final camera = _cameras!.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras!.first,
        );

        _controller = CameraController(
          camera,
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _controller!.initialize();
      }
    } catch (e) {
      debugPrint('Camera init failed: $e');
      // On web or emulators without cameras, we just swallow the error
      // so the user can still use the "Upload from Gallery" fallback.
    }
    
    if (mounted) {
      setState(() => _isInitialized = true);
      _startQualitySimulation();
    }
  }

  // ────────────────────────────────────────────────────────────────────
  // QUALITY SIMULATION
  // ────────────────────────────────────────────────────────────────────
  void _startQualitySimulation() {
    _qualityTimer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      if (!mounted || _capturedImagePath != null) return;
      final rand = math.Random();

      // Lighting
      final ls = 0.50 + rand.nextDouble() * 0.50;
      String ll;
      Color lc;
      if (ls > 0.82) {
        ll = 'Excellent';
        lc = AppTheme.statusGreen;
      } else if (ls > 0.62) {
        ll = 'Adequate';
        lc = AppTheme.statusYellow;
      } else {
        ll = 'Low';
        lc = AppTheme.statusRed;
      }

      // Quality
      final qs = 0.55 + rand.nextDouble() * 0.45;
      String ql;
      Color qc;
      if (qs > 0.80) {
        ql = 'Clear';
        qc = AppTheme.statusGreen;
      } else if (qs > 0.60) {
        ql = 'Acceptable';
        qc = AppTheme.statusYellow;
      } else {
        ql = 'Blurry';
        qc = AppTheme.statusRed;
      }

      setState(() {
        _lightingScore = ls;
        _lightingLabel = ll;
        _lightingColor = lc;
        _qualityScore = qs;
        _qualityLabel = ql;
        _qualityColor = qc;
        _eyeDetected = ls > 0.62 && qs > 0.60;
      });
    });
  }

  // ────────────────────────────────────────────────────────────────────
  // ACTIONS
  // ────────────────────────────────────────────────────────────────────
  Future<void> _captureImage() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }
    setState(() => _isCapturing = true);

    await _captureFlash.forward();
    await _captureFlash.reverse();

    try {
      final XFile file = await _controller!.takePicture();
      if (mounted) {
        _qualityTimer?.cancel();
        setState(() {
          _capturedImagePath = file.path;
          _isCapturing = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (file != null && mounted) {
        _qualityTimer?.cancel();
        setState(() => _capturedImagePath = file.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not open gallery.'),
            backgroundColor: AppTheme.statusRed,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _retake() {
    setState(() => _capturedImagePath = null);
    _startQualitySimulation();
  }

  void _continueToPreparation() {
    if (_capturedImagePath == null) return;
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, _) => AiImagePreparationScreen(
          imagePath: _capturedImagePath!,
          category: widget.category,
        ),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _qualityTimer?.cancel();
    _controller?.dispose();
    _pulseAnim.dispose();
    _scanLineAnim.dispose();
    _cornerGlowAnim.dispose();
    _captureFlash.dispose();
    _fadeInAnim.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    if (_initError != null) return _buildErrorScreen();
    if (!_isInitialized) return _buildLoadingScreen();

    return Scaffold(
      backgroundColor: Colors.black,
      body: _capturedImagePath != null
          ? _buildPreviewMode()
          : _buildCameraMode(),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  LOADING
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: _bgDark,
      body: Center(
        child: FadeTransition(
          opacity: _fadeInAnim,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, _) => Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.aiTeal
                        .withValues(alpha: 0.06 + 0.06 * _pulseAnim.value),
                    border: Border.all(
                      color: AppTheme.aiTeal
                          .withValues(alpha: 0.30 + 0.30 * _pulseAnim.value),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(Icons.remove_red_eye_outlined,
                      color: AppTheme.aiTeal, size: 32),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Initializing Camera',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Setting up AI Eye Screening',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.aiTeal.withValues(alpha: 0.6)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  ERROR
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildCloseButton(),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.04),
                          border:
                              Border.all(color: Colors.white10, width: 1.5),
                        ),
                        child: const Icon(Icons.no_photography_outlined,
                            color: Colors.white30, size: 38),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        kIsWeb ? 'Camera Not Available' : 'Camera Error',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _initError!,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 14, height: 1.6),
                        textAlign: TextAlign.center,
                      ),
                      if (kIsWeb) ...[
                        const SizedBox(height: 28),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.aiTeal.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: AppTheme.aiTeal.withValues(alpha: 0.25)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.smartphone_rounded,
                                  color: AppTheme.aiTeal, size: 18),
                              SizedBox(width: 10),
                              Text(
                                'Use the VisionAI mobile app',
                                style: TextStyle(
                                    color: AppTheme.aiTeal,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white38, size: 18),
                        label: const Text('Go Back',
                            style: TextStyle(
                                color: Colors.white38, fontSize: 14)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  CAMERA MODE
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildCameraMode() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera feed
        if (_controller != null)
          CameraPreview(_controller!)
        else
          Container(
            color: Colors.black,
            child: const Center(
              child: Icon(CupertinoIcons.camera_fill, color: Colors.white24, size: 64),
            ),
          ),

        // Radial vignette
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.60),
              ],
            ),
          ),
        ),

        // Flash overlay
        AnimatedBuilder(
          animation: _captureFlash,
          builder: (_, _) => _captureFlash.value > 0
              ? Container(
                  color:
                      Colors.white.withValues(alpha: _captureFlash.value * 0.65))
              : const SizedBox.shrink(),
        ),

        // Main UI
        SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              const SizedBox(height: 4),
              _buildSubtitle(),
              const Spacer(flex: 2),
              _buildEyeGuide(),
              const Spacer(flex: 1),
              _buildStatusIndicators(),
              const SizedBox(height: 16),
              _buildInfoCard(),
              const SizedBox(height: 20),
              _buildCaptureActions(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  // ── Top Bar ─────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          // Back button
          _glassPill(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 17),
            circle: true,
          ),
          const Spacer(),

          // Title badge
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: AppTheme.aiTeal,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.aiTeal.withValues(alpha: 0.6),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'AI EYE SCREENING',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Spacer(),
          const SizedBox(width: 40), // Balance with back button
        ],
      ),
    );
  }

  // ── Subtitle ────────────────────────────────────────────────────────
  Widget _buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        'Position your eye inside the guide for a clear image.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.60),
          fontSize: 13.5,
          height: 1.5,
          letterSpacing: 0.15,
        ),
      ),
    );
  }

  // ── Eye Guide ───────────────────────────────────────────────────────
  Widget _buildEyeGuide() {
    return Center(
      child: SizedBox(
        width: _guideDiameter,
        height: _guideDiameter,
        child: Stack(
          children: [
            // Animated ellipse border
            AnimatedBuilder(
              animation: _cornerGlowAnim,
              builder: (_, _) {
                final detected = _eyeDetected;
                final borderColor = detected
                    ? AppTheme.aiTeal
                    : Colors.white.withValues(alpha: 0.45);
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: borderColor.withValues(
                          alpha: 0.50 + 0.40 * _cornerGlowAnim.value),
                      width: detected ? 2.5 : 1.8,
                    ),
                    boxShadow: detected
                        ? [
                            BoxShadow(
                              color: AppTheme.aiTeal.withValues(
                                  alpha: 0.15 + 0.12 * _cornerGlowAnim.value),
                              blurRadius: 28,
                              spreadRadius: 6,
                            ),
                          ]
                        : [],
                  ),
                );
              },
            ),

            // Corner bracket marks
            ..._buildCornerBrackets(),

            // Horizontal scan line
            AnimatedBuilder(
              animation: _scanLineAnim,
              builder: (_, _) {
                final t = _scanLineAnim.value;
                final top = _guideDiameter * t;
                return Positioned(
                  top: top.clamp(0.0, _guideDiameter - 2),
                  left: 20,
                  right: 20,
                  child: Opacity(
                    opacity: (math.sin(t * math.pi) * 0.9).clamp(0.0, 1.0),
                    child: Container(
                      height: 1.2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppTheme.aiTeal.withValues(alpha: 0.85),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.aiTeal.withValues(alpha: 0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Centre crosshair
            Center(
              child: AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, _) {
                  final s = 5.0 + 2.0 * _pulseAnim.value;
                  return Container(
                    width: s,
                    height: s,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.aiTeal.withValues(alpha: 0.65),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.aiTeal.withValues(alpha: 0.45),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Thin crosshair lines
            Center(
              child: SizedBox(
                width: 48,
                height: 48,
                child: CustomPaint(painter: _CrosshairPainter()),
              ),
            ),

            // Eye detected badge
            if (_eyeDetected)
              Positioned(
                bottom: 14,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _eyeDetected ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 350),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.statusGreen.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.statusGreen.withValues(alpha: 0.35),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: Colors.white, size: 13),
                          SizedBox(width: 6),
                          Text(
                            'Eye Detected',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Corner brackets ─────────────────────────────────────────────────
  List<Widget> _buildCornerBrackets() {
    const len = 22.0;
    const thickness = 2.2;
    const inset = 16.0;

    Widget bracket(
        Alignment align, bool top, bool left) {
      return Align(
        alignment: align,
        child: Padding(
          padding: const EdgeInsets.all(inset),
          child: AnimatedBuilder(
            animation: _cornerGlowAnim,
            builder: (_, _) => Container(
              width: len,
              height: len,
              decoration: BoxDecoration(
                border: Border(
                  top: top
                      ? BorderSide(
                          color: AppTheme.aiTeal.withValues(
                              alpha: 0.6 + 0.35 * _cornerGlowAnim.value),
                          width: thickness)
                      : BorderSide.none,
                  bottom: !top
                      ? BorderSide(
                          color: AppTheme.aiTeal.withValues(
                              alpha: 0.6 + 0.35 * _cornerGlowAnim.value),
                          width: thickness)
                      : BorderSide.none,
                  left: left
                      ? BorderSide(
                          color: AppTheme.aiTeal.withValues(
                              alpha: 0.6 + 0.35 * _cornerGlowAnim.value),
                          width: thickness)
                      : BorderSide.none,
                  right: !left
                      ? BorderSide(
                          color: AppTheme.aiTeal.withValues(
                              alpha: 0.6 + 0.35 * _cornerGlowAnim.value),
                          width: thickness)
                      : BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return [
      bracket(Alignment.topLeft, true, true),
      bracket(Alignment.topRight, true, false),
      bracket(Alignment.bottomLeft, false, true),
      bracket(Alignment.bottomRight, false, false),
    ];
  }

  // ── Status Indicators ───────────────────────────────────────────────
  Widget _buildStatusIndicators() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                // Lighting
                Expanded(child: _statusItem(
                  icon: Icons.wb_sunny_rounded,
                  label: 'Lighting',
                  value: _lightingLabel,
                  score: _lightingScore,
                  color: _lightingColor,
                )),
                Container(
                  width: 1,
                  height: 36,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                // Quality
                Expanded(child: _statusItem(
                  icon: Icons.center_focus_strong_rounded,
                  label: 'Quality',
                  value: _qualityLabel,
                  score: _qualityScore,
                  color: _qualityColor,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusItem({
    required IconData icon,
    required String label,
    required String value,
    required double score,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55), fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            value,
            key: ValueKey(value),
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              height: 3,
              child: LinearProgressIndicator(
                value: score,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Info Card ───────────────────────────────────────────────────────
  Widget _buildInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.aiTeal.withValues(alpha: 0.12),
                  ),
                  child: const Icon(Icons.lightbulb_outline_rounded,
                      color: AppTheme.aiTeal, size: 14),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'For best results, use good lighting and keep the eye clearly visible.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.58),
                      fontSize: 11.5,
                      height: 1.4,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Capture Actions ─────────────────────────────────────────────────
  Widget _buildCaptureActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Capture button
          GestureDetector(
            onTap: _isCapturing ? null : _captureImage,
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, _) => Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Colors.white, Color(0xFFF0F0F0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Colors.white
                        .withValues(alpha: 0.3 + 0.15 * _pulseAnim.value),
                    width: 3.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.aiTeal
                          .withValues(alpha: 0.20 + 0.15 * _pulseAnim.value),
                      blurRadius: 24 + 8 * _pulseAnim.value,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.30),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _isCapturing
                    ? const CupertinoActivityIndicator(
                        radius: 14, color: AppTheme.primaryNavy)
                    : const Icon(Icons.remove_red_eye_rounded,
                        color: AppTheme.primaryNavy, size: 28),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Capture Eye',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.70),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 16),

          // Upload from gallery
          GestureDetector(
            onTap: _pickFromGallery,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library_rounded,
                          color: Colors.white.withValues(alpha: 0.75), size: 18),
                      const SizedBox(width: 10),
                      Text(
                        'Upload from Gallery',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.80),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Glassmorphism helper ────────────────────────────────────────────
  Widget _glassPill({
    required Widget child,
    VoidCallback? onTap,
    bool circle = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(circle ? 40 : 20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: circle ? 42 : null,
            height: circle ? 42 : null,
            padding: circle ? null : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              shape: circle ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: circle ? null : BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  PREVIEW MODE (after capture / gallery pick)
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildPreviewMode() {
    return Container(
      color: _bgDark,
      child: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  _glassPill(
                    onTap: _retake,
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white70, size: 17),
                    circle: true,
                  ),
                  const Expanded(
                    child: Text(
                      'Review Image',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 42),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Image preview
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      kIsWeb
                          ? Image.network(
                              _capturedImagePath!,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(_capturedImagePath!),
                              fit: BoxFit.cover,
                            ),

                      // Top gradient
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.40),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Badge
                      Positioned(
                        top: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.40),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.12)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: AppTheme.statusGreen,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.statusGreen
                                                .withValues(alpha: 0.5),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'IMAGE CAPTURED',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Bottom gradient
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.35),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Validation note
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                decoration: BoxDecoration(
                  color: AppTheme.aiTeal.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: AppTheme.aiTeal.withValues(alpha: 0.18)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.aiTeal.withValues(alpha: 0.12),
                      ),
                      child: const Icon(Icons.shield_outlined,
                          color: AppTheme.aiTeal, size: 14),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'AI analysis begins only after image passes quality validation.',
                        style: TextStyle(
                            color: AppTheme.aiTeal,
                            fontSize: 11.5,
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Retake
                  Expanded(
                    child: GestureDetector(
                      onTap: _retake,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.replay_rounded,
                                color: Colors.white.withValues(alpha: 0.65),
                                size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Retake',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.70),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Continue
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _continueToPreparation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primaryTeal, AppTheme.aiTeal],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.aiTeal.withValues(alpha: 0.30),
                              blurRadius: 18,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome_rounded,
                                color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Continue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
//  CROSSHAIR PAINTER
// ════════════════════════════════════════════════════════════════════════
class _CrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 0.8;

    final cx = size.width / 2;
    final cy = size.height / 2;
    const gap = 6.0;

    // Horizontal
    canvas.drawLine(Offset(0, cy), Offset(cx - gap, cy), paint);
    canvas.drawLine(Offset(cx + gap, cy), Offset(size.width, cy), paint);
    // Vertical
    canvas.drawLine(Offset(cx, 0), Offset(cx, cy - gap), paint);
    canvas.drawLine(Offset(cx, cy + gap), Offset(cx, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
