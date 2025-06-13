// @dart=2.9

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:mobile/Products/pdpay/layout/cs.dart';
import 'package:mobile/Products/pdpay/layout/home1.dart';
import 'package:mobile/Products/pdpay/layout/profile.dart';
import 'package:mobile/Products/pdpay/layout/history.dart';
import 'package:mobile/screen/kasir/main.dart';

class HomeBlibli extends StatefulWidget {
  @override
  _HomeBlibliState createState() => _HomeBlibliState();
}

class _HomeBlibliState extends State<HomeBlibli> {
  int pageIndex = 0;
  List<Widget> halaman = [PayuniHome(), HistoryPage(), CS1(), ProfilePopay()];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
            backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.storefront_rounded),
        elevation: 0.0,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MainKasir(),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: halaman[pageIndex],
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        activeIndex: pageIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.verySmoothEdge,
        itemCount: 4,
        tabBuilder: (i, isActive) {
          Color color = isActive ? Theme.of(context).primaryColor : Colors.grey;
          IconData icon;
          String label;

          if (i == 0) {
            icon = Icons.home_rounded;
            label = 'Beranda';
          } else if (i == 1) {
            icon = Icons.history_rounded;
            label = 'Riwayat';
          } else if (i == 2) {
            icon = Icons.forum_rounded;
            label = 'Livechat';
          } else if (i == 3) {
            icon = Icons.person_rounded;
            label = 'Profil';
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 22,
              ),
              SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                ),
              ),
            ],
          );
        },
        onTap: (index) {
          setState(() {
            pageIndex = index;
          });
        },
      ),
    );
  }
}
