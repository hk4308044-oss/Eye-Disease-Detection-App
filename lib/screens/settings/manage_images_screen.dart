import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';

class ManageImagesScreen extends StatefulWidget {
  const ManageImagesScreen({super.key});

  @override
  State<ManageImagesScreen> createState() => _ManageImagesScreenState();
}

class _ManageImagesScreenState extends State<ManageImagesScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<String> _imageUrls = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final urls = await _firebaseService.getUserImages();
      if (mounted) {
        setState(() {
          _imageUrls = urls;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _hideLoadingDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _handleDelete(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Image"),
        content: const Text("Are you sure you want to permanently delete this eye image?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              _showLoadingDialog();
              try {
                await _firebaseService.deleteImage(url);
                if (mounted) {
                  _hideLoadingDialog();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image deleted.")));
                  _loadImages();
                }
              } catch (e) {
                if (mounted) {
                  _hideLoadingDialog();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error deleting image: $e")));
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _viewFullScreen(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  _handleDelete(url);
                },
              ),
            ],
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(url),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.darkNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Manage Eye Images",
          style: TextStyle(
            color: AppTheme.darkNavy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text("Error loading images:\n$_error", textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadImages,
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (_imageUrls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_outlined, color: Colors.grey[400], size: 64),
            const SizedBox(height: 16),
            const Text(
              "No captured eye images found.",
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _imageUrls.length,
      itemBuilder: (context, index) {
        final url = _imageUrls[index];
        return GestureDetector(
          onTap: () => _viewFullScreen(url),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _handleDelete(url),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
