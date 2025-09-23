import 'package:flutter/material.dart';
import 'main.dart';
import 'package:mobile/utils/debug_helper.dart';
import 'package:mobile/Products/santren/layout/onboarding.dart';
import 'package:mobile/Products/santren/layout/index.dart';
import 'package:mobile/Products/santren/color.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(SantrenApp());
}

class SantrenApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Santren Pay',
      theme: colors,
      home: OnboardingWrapper(),
      routes: {
        '/home': (context) => EpulsaHome(),
      },
    );
  }
}

class OnboardingWrapper extends StatefulWidget {
  @override
  _OnboardingWrapperState createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  bool _showOnboarding = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool hasSeenOnboarding = prefs.getBool('santren_onboarding_seen') ?? false;
      
      setState(() {
        _showOnboarding = !hasSeenOnboarding;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _showOnboarding = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('santren_onboarding_seen', true);
      
      setState(() {
        _showOnboarding = false;
      });
    } catch (e) {
      DebugHelper.debugPrint('Error saving onboarding status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFF0652DD),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.flash_on,
                  color: Color(0xFF0652DD),
                  size: 40,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Santren Pay',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (_showOnboarding) {
      return SantrenOnboardingScreen();
    }

    return EpulsaHome();
  }
}
