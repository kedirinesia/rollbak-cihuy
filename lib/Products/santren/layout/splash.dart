import 'package:flutter/material.dart';
import 'package:mobile/utils/debug_helper.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/img/santren/splash_screen1.jpg',
      fit: BoxFit.cover,
    );
  }
}
