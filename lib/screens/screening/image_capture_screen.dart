import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../models/pre_screening_assessment.dart';
import 'image_quality_screen.dart';

class ImageCaptureScreen extends StatefulWidget {
  final PreScreeningAssessment? assessment;

  const ImageCaptureScreen({super.key, this.assessment});

  @override
  State<ImageCaptureScreen> createState() => _ImageCaptureScreenState();
}

class _ImageCaptureScreenState extends State<ImageCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  
  bool _isCameraReady = false;
  String? _capturedImagePath;

  // Design constants
  static const Color primaryNavy = Color(0xFF0F172A);
  static const Color slateGrey = Color(0xFF475569);
  static const Color primaryTeal = Color(0xFF0891B2);
  static const Color bgLight = Color(0xFFF8FAFC);
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        CameraDescription camera = _cameras!.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras!.first,
        );
        _cameraController = CameraController(
          camera,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraReady = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Camera initialization failed: $e");
    }
  }

  Future<void> _captureWithSmartCamera() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Camera is not available. Please use "Upload from Gallery" instead.')));
      return;
    }
    try {
      final XFile image = await _cameraController!.takePicture();
      if (mounted) {
        setState(() {
          _capturedImagePath = image.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to capture: $e')));
    }
  }

  Future<void> _captureWithPicker(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() {
          _capturedImagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load image: $e')));
    }
  }

  void _proceedToQualityCheck() {
    if (_capturedImagePath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageQualityScreen(
            assessment: widget.assessment ?? PreScreeningAssessment(),
            imagePath: _capturedImagePath!,
          ),
        ),
      );
    }
  }

  void _retake() {
    setState(() {
      _capturedImagePath = null;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: primaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "AI Eye Screening",
          style: TextStyle(color: primaryNavy, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: const Text(
                          "Position your eye inside the guide for a clear image.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: slateGrey, 
                            fontSize: 15, 
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _capturedImagePath != null ? _buildImagePreview() : _buildCameraPreview(),
                        ),
                      ),
                      if (_capturedImagePath == null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: primaryTeal.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: primaryTeal.withOpacity(0.1)),
                            ),
                            child: Row(
                              children: [
                                const Icon(CupertinoIcons.info_circle_fill, color: primaryTeal, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "For best results, use good lighting and keep the eye clearly visible.",
                                    style: TextStyle(color: primaryNavy.withOpacity(0.8), fontSize: 13, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                        child: _capturedImagePath != null ? _buildPreviewActions() : _buildCaptureActions(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_isCameraReady)
              CameraPreview(_cameraController!)
            else
              Center(
                child: Icon(CupertinoIcons.camera_fill, color: Colors.white.withOpacity(0.2), size: 64),
              ),
            CustomPaint(
              painter: EyeGuidePainter(),
              size: Size.infinite,
            ),
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(CupertinoIcons.sun_max_fill, color: Colors.amber, size: 14),
                    SizedBox(width: 6),
                    Text("Good Lighting", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))
                    ]
                  ),
                  child: const Text("Optimal Distance", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        image: DecorationImage(
          image: kIsWeb 
              ? NetworkImage(_capturedImagePath!) as ImageProvider
              : FileImage(File(_capturedImagePath!)),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildCaptureActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _captureWithSmartCamera,
            icon: const Icon(CupertinoIcons.camera_fill, color: Colors.white),
            label: const Text("Capture Eye", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryTeal,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () => _captureWithPicker(ImageSource.gallery),
            icon: const Icon(CupertinoIcons.photo, color: slateGrey),
            label: const Text("Upload from Gallery", style: TextStyle(color: slateGrey, fontSize: 16, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: slateGrey.withOpacity(0.3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewActions() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton(
              onPressed: _retake,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: slateGrey),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Retake", style: TextStyle(color: slateGrey, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _proceedToQualityCheck,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Continue", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }
}

class EyeGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    
    // Draw an eye shape guide in the center
    final center = Offset(size.width / 2, size.height / 2);
    final width = size.width * 0.65;
    final height = width * 0.55;
    
    path.moveTo(center.dx - width / 2, center.dy);
    path.quadraticBezierTo(center.dx, center.dy - height / 2, center.dx + width / 2, center.dy);
    path.quadraticBezierTo(center.dx, center.dy + height / 2, center.dx - width / 2, center.dy);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Draw subtle crosshairs
    final dashPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
      
    canvas.drawLine(Offset(center.dx, center.dy - 12), Offset(center.dx, center.dy + 12), dashPaint);
    canvas.drawLine(Offset(center.dx - 12, center.dy), Offset(center.dx + 12, center.dy), dashPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
