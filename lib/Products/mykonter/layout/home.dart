import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/Products/mykonter/layout/cs.dart';
import 'package:mobile/Products/mykonter/layout/home1.dart';
import 'package:mobile/Products/mykonter/layout/profile.dart';
import 'package:mobile/Products/mykonter/layout/history.dart';
import 'package:mobile/screen/kasir/main.dart';

class HomePopay extends StatefulWidget {
  @override
  _HomePopayState createState() => _HomePopayState();
}

class _HomePopayState extends State<HomePopay> {
  int pageIndex = 0;
  List<Widget> halaman = [
    GrabHome(),
    HistoryPage(),
    MainKasir(),
    CustomerServicePage(),
    ProfilePopay(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
            backgroundColor: Colors.grey[100],
      body: halaman[pageIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageIndex,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        unselectedItemColor: Colors.grey,
        unselectedFontSize: 10,
        selectedItemColor: Theme.of(context).primaryColor,
        selectedLabelStyle: TextStyle(fontSize: 11),
        onTap: (index) {
          setState(() {
            pageIndex = index;
          });
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_rounded), label: 'Kasir'),
          BottomNavigationBarItem(icon: Icon(Icons.message_rounded), label: 'CS'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil')
        ],
      ),
    );
  }
}
