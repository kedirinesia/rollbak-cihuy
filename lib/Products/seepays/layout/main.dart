// @dart=2.9

import 'package:flutter/material.dart';
import 'package:mobile/Products/seepays/layout/history.dart';
import 'package:mobile/Products/seepays/layout/home2.dart';
import 'package:mobile/Products/seepays/layout/profile.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/component/webview.dart';
import 'package:motion_tab_bar_v2/motion-tab-bar.dart';
import 'package:motion_tab_bar_v2/motion-tab-controller.dart';
import 'package:flutter_svg/flutter_svg.dart'; // <--- Tambahkan ini

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with TickerProviderStateMixin {
  MotionTabBarController _motionTabBarController;
  final List<Widget> _pages = [
    Home2App(),
    HistoryPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _motionTabBarController = MotionTabBarController(
      initialIndex: 0,
      length: _pages.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _motionTabBarController.dispose();
    super.dispose();
  }

  List<Widget> _buildNavIcons(BuildContext context) {
    return [
      Icon(Icons.apps, size: 28), // Home tetap Icon Flutter
      SvgPicture.asset(
        "assets/staggered-menu.svg",
        width: 28,
        height: 28,
        color: Colors.grey, // warna icon history nonselected
      ),
      Image.asset(
        "assets/profile.png",
        width: 28,
        height: 28,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      body: TabBarView(
        controller: _motionTabBarController,
        physics: NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: MotionTabBar(
        labels: ["Home", "History", "Profile"],
        initialSelectedTab: "Home",
        iconWidgets: _buildNavIcons(context),
        controller: _motionTabBarController,
        tabBarColor: Colors.white,
        tabSelectedColor: Colors.deepPurpleAccent,
        tabIconColor: Colors.grey,
        tabIconSelectedColor: Colors.white,
        textStyle: TextStyle(
          fontSize: 12,
          color: Colors.deepPurpleAccent,
          fontWeight: FontWeight.w500,
        ),
        onTabItemSelected: (int index) {
          setState(() {
            _motionTabBarController.index = index;
          });
        },
      ),
    );
  }
}
