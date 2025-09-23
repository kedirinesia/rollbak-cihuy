// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SantrenOnboardingScreen extends StatefulWidget {
  @override
  _SantrenOnboardingScreenState createState() => _SantrenOnboardingScreenState();
}

class _SantrenOnboardingScreenState extends State<SantrenOnboardingScreen>
    with TickerProviderStateMixin {
  PageController _pageController = PageController();
  int _currentPage = 0;
  AnimationController _animationController;
  Animation<double> _fadeAnimation;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: "SOLUSI CERDAS UNTUK ANDA",
      description: "NIKMATI BERBAGAI\nLAYANAN",
      icon: Icons.account_balance_wallet,
      color: Color(0xFF2ECC71),
      services: [
        ServiceIcon(icon: Icons.sim_card, label: "Pulsa"),
        ServiceIcon(icon: Icons.grid_view, label: "Layanan"),
        ServiceIcon(icon: Icons.account_balance_wallet, label: "E-Wallet"),
        ServiceIcon(icon: Icons.point_of_sale, label: "DigiPOS"),
        ServiceIcon(icon: Icons.sync, label: "Transfer"),
      ],
    ),
    OnboardingPage(
      title: "PEMBAYARAN MUDAH",
      description: "BAYAR SEMUA KEBUTUHAN\nDENGAN SATU APLIKASI",
      icon: Icons.payment,
      color: Color(0xFF2ECC71),
      services: [
        ServiceIcon(icon: Icons.qr_code, label: "QRIS"),
        ServiceIcon(icon: Icons.phone_android, label: "Pulsa"),
        ServiceIcon(icon: Icons.electric_bolt, label: "Token"),
        ServiceIcon(icon: Icons.credit_card, label: "Kartu"),
        ServiceIcon(icon: Icons.shopping_cart, label: "Belanja"),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    
    // Set status bar to match background
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xFF2ECC71),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF2ECC71),
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    // Save onboarding completion status
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('santren_onboarding_seen', true);
    } catch (e) {
      print('Error saving onboarding status: $e');
    }
    
    // Navigate to main app
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return Material(
      color: Color(0xFF2ECC71),
      child: SafeArea(
        top: false,
        bottom: false,
        left: false,
        right: false,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Color(0xFF2ECC71),
          child: Column(
          children: [
            // Main Content
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
                  return _buildOnboardingPage(_pages[index], screenWidth, screenHeight);
                },
              ),
            ),
            
            // Bottom Section
            Container(
              width: double.infinity,
              color: Color(0xFF2ECC71),
              child: Column(
                children: [
                  // Continue Button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            side: BorderSide(color: Colors.black, width: 1),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "LANJUT",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Terms and Website
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              "Syarat & Ketentuan",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "santren.web.id",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Page Indicators
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: index == _currentPage ? Color(0xFF2ECC71) : Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildOnboardingPage(OnboardingPage page, double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: page.color,
      child: Column(
        children: [
          // Top Section with White Background
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 3D Graphic Representation
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: screenHeight * 0.25,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // E-wallet icon
                          Positioned(
                            left: screenWidth * 0.1,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.account_balance_wallet,
                                size: 40,
                                color: page.color,
                              ),
                            ),
                          ),
                          // Communication tower
                          Positioned(
                            right: screenWidth * 0.1,
                            child: Column(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.signal_cellular_4_bar,
                                    size: 30,
                                    color: page.color,
                                  ),
                                ),
                                SizedBox(height: 10),
                                // Signal waves
                                Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.yellow,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    SizedBox(width: 2),
                                    Container(
                                      width: 4,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.yellow,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    SizedBox(width: 2),
                                    Container(
                                      width: 4,
                                      height: 25,
                                      decoration: BoxDecoration(
                                        color: Colors.yellow,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Title
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      page.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.yellow,
                            blurRadius: 2,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // App Logo and Name
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: page.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.flash_on,
                            color: page.color,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Santren",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Pay",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Section with Green Background
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              color: page.color,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.yellow,
                              blurRadius: 2,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // App Logo and Name
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: page.color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.flash_on,
                              color: page.color,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Santren",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Pay",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Service Icons
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.yellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: page.services.map((service) {
                          return Column(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  service.icon,
                                  color: page.color,
                                  size: 20,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                service.label,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Description
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      page.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
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
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<ServiceIcon> services;

  OnboardingPage({
    this.title,
    this.description,
    this.icon,
    this.color,
    this.services,
  });
}

class ServiceIcon {
  final IconData icon;
  final String label;

  ServiceIcon({
    this.icon,
    this.label,
  });
}
