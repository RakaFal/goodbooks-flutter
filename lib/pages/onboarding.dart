import 'package:flutter/material.dart';
import 'package:goodbooks_flutter/base/navbar.dart';
import 'package:provider/provider.dart';
import 'package:goodbooks_flutter/provider/auth_provider.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isNavigating = false;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      image: 'assets/images/onboarding1.jpg',
      title: 'Welcome to GoodBooks',
      description: 'GoodBooks is a platform to share and read books also you can buy licensed books here.',
    ),
    OnboardingItem(
      image: 'assets/images/onboarding2.jpg',
      title: 'Sell and Buy Books easily',
      description: 'Transaction is easy and secure, you can sell and buy books with just a few clicks.',
    ),
    OnboardingItem(
      image: 'assets/images/onboarding3.jpg',
      title: 'Delivery faster and secure',
      description: 'Books are sent with special packaging and the delivery status can be tracked.',
    )
  ];

  Future<void> _navigateAfterOnboarding() async {
    if (_isNavigating || !mounted) return;
    _isNavigating = true;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkLoginStatus();

      if (!mounted) return;
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const NavBar(),
        ),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const NavBar()),
        (route) => false,
      );
    } finally {
      _isNavigating = false;
    }
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardingItems.length,
            onPageChanged: (index) {
              if (mounted) setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return OnboardingScreen(item: _onboardingItems[index]);
            },
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingItems.length,
                      (index) => _buildDot(index: index),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        if (_currentPage != _onboardingItems.length - 1)
                          TextButton(
                            onPressed: _navigateAfterOnboarding,
                            child: const Text(
                              'Skip',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () async {
                            if (_currentPage == _onboardingItems.length - 1) {
                              await _navigateAfterOnboarding();
                            } else {
                              await _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(54, 105, 201, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          ),
                          child: Text(
                            _currentPage == _onboardingItems.length - 1
                                ? 'Get Started'
                                : 'Next',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 6),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color.fromRGBO(54, 105, 201, 1)
            : Colors.grey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingItem {
  final String image;
  final String title;
  final String description;

  const OnboardingItem({
    required this.image,
    required this.title,
    required this.description,
  });
}

class OnboardingScreen extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            item.image,
            height: MediaQuery.of(context).size.height * 0.5,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
          ),
          const SizedBox(height: 40),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            item.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}