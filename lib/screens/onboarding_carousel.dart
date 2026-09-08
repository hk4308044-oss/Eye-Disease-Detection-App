import 'package:flutter/material.dart';
import 'auth/login_screen.dart';

class OnboardingCarousel extends StatefulWidget {
  const OnboardingCarousel({super.key});

  @override
  State<OnboardingCarousel> createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends State<OnboardingCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      "title": "AI-Powered Screening",
      "description": "Analyze an eye image using intelligent AI technology for quick preliminary assessment."
    },
    {
      "title": "Track Your Health",
      "description": "Keep a timeline of your eye health and receive personalized daily care tips."
    },
    {
      "title": "Find Specialists",
      "description": "Easily locate and book appointments with top-rated ophthalmologists nearby."
    }
  ];

  void _onSkip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _onNext() {
    if (_currentPage == _pages.length - 1) {
      _onSkip();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _onSkip,
                child: Text(
                  "Skip",
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            color: colorScheme.secondary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            index == 0 
                                ? Icons.remove_red_eye_outlined
                                : index == 1
                                    ? Icons.auto_graph
                                    : Icons.person_search,
                            size: 100,
                            color: colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 64),
                        Text(
                          _pages[index]["title"]!,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _pages[index]["description"]!,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
              ),
            ),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? colorScheme.secondary
                        : colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onNext,
                  child: Text(_currentPage == _pages.length - 1 ? "Get Started" : "Continue"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
