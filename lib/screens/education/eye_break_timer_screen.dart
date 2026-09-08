import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:math';

class EyeBreakTimerScreen extends StatefulWidget {
  const EyeBreakTimerScreen({super.key});

  @override
  State<EyeBreakTimerScreen> createState() => _EyeBreakTimerScreenState();
}

class _EyeBreakTimerScreenState extends State<EyeBreakTimerScreen> with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _progressController;
  
  bool _isRunning = false;
  int _secondsRemaining = 20;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _progressController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      _progressController.stop();
      setState(() => _isRunning = false);
    } else {
      if (_secondsRemaining == 0) {
        _secondsRemaining = 20;
        _progressController.reset();
      }
      setState(() => _isRunning = true);
      _progressController.forward();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsRemaining > 0) {
          setState(() {
            _secondsRemaining--;
          });
        } else {
          _timer?.cancel();
          setState(() => _isRunning = false);
          _showCompletionDialog();
        }
      });
    }
  }

  void _showCompletionDialog() {
    final textTheme = Theme.of(context).textTheme;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            const Icon(CupertinoIcons.checkmark_seal_fill, color: AppTheme.statusGreen, size: 64),
            const SizedBox(height: 16),
            Text("Great Job!", style: textTheme.headlineMedium),
          ],
        ),
        content: Text(
          "You've completed your eye rest. Your eyes thank you for taking a break from the screen.",
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(height: 1.5),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _secondsRemaining = 20;
                  _progressController.reset();
                });
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Done"),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Immersive dark mode for resting eyes, even if system is light mode
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Theme.of(context).colorScheme.background : AppTheme.primaryNavy;
    final textColor = Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Eye Relaxation",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Text(
                "20-20-20 Rule",
                style: TextStyle(
                  color: AppTheme.aiTeal,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontFamily: 'Inter'
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                "Look at an object 20 feet away for 20 seconds.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 18,
                  height: 1.4,
                  fontFamily: 'Inter'
                ),
              ),
            ),
            const Spacer(),
            
            // Breathing Animation & Timer
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _breathingController,
                    builder: (context, child) {
                      return Container(
                        width: 280 + (_breathingController.value * 40),
                        height: 280 + (_breathingController.value * 40),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.aiTeal.withOpacity(0.05 + (_breathingController.value * 0.1)),
                        ),
                      );
                    }
                  ),
                  
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return CircularProgressIndicator(
                          value: 1.0 - _progressController.value,
                          strokeWidth: 8,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          color: AppTheme.aiTeal,
                          strokeCap: StrokeCap.round,
                        );
                      }
                    ),
                  ),
                  
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _secondsRemaining.toString().padLeft(2, '0'),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 72,
                          fontWeight: FontWeight.w200,
                          letterSpacing: -2,
                          fontFamily: 'Inter'
                        ),
                      ),
                      const Text(
                        "SECONDS",
                        style: TextStyle(
                          color: AppTheme.aiTeal,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontFamily: 'Inter'
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            Padding(
              padding: const EdgeInsets.only(bottom: 64),
              child: GestureDetector(
                onTap: _toggleTimer,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _isRunning ? Colors.white.withOpacity(0.1) : AppTheme.aiTeal,
                    shape: BoxShape.circle,
                    border: _isRunning ? Border.all(color: Colors.white.withOpacity(0.3), width: 2) : null,
                    boxShadow: _isRunning ? null : [
                      BoxShadow(
                        color: AppTheme.aiTeal.withOpacity(0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Icon(
                    _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: _isRunning ? Colors.white : AppTheme.primaryNavy,
                    size: 40,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
