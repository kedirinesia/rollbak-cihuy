import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/Products/payku/layout/wizard/model_wizard.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  Timer? _timer;

  int _activePage = 0;

  @override
  void initState() {
    super.initState();
    // Mengatur timer untuk otomatis pindah ke halaman berikutnya setelah 3 detik
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_activePage < _pages.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.linear,
        );
      } else {
        timer.cancel();
      }
    });
  }

  void onNextPage() {
    if (_activePage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.linear,
      );
    }
  }

  // void onSkip() {
  //   if (_activePage < _pages.length - 1) {
  //     _pageController.animateToPage(_activePage + 1,
  //         duration: const Duration(milliseconds: 500), curve: Curves.linear);
  //   }
  // }
  void onSkip() {
    int lastPageIndex = _pages.length - 1;
    _pageController.animateToPage(
      lastPageIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.linear,
    );
  }

  final List<Map<String, dynamic>> _pages = [
    {
      'color': '#F5AB35',
      'title': 'Selamat Datang',
      'image': 'assets/img/payku/wizardNew1.png',
      'description':
          "Payku adalah aplikasi untuk memudahkan para Sahabat dalam memenuhi kebutuhan sehari-hari.",
      'skip': true
    },
    {
      'color': '#F5AB35',
      'title': 'Full Fitur',
      'image': 'assets/img/payku/wizardNew3.png',
      'description':
          'Disini kamu akan menemukan banyak fitur seperti Kasir, QRIS Static, Print Struk, Promo Produk, Reward Poin, dan masih banyak lainnya.',
      'skip': true
    },
    {
      'color': '#F5AB35',
      'title': 'Raih Keuntungan Sekarang',
      'image': 'assets/img/payku/wizardNew2.png',
      'description':
          'Tunggu apa lagi? Ayo pakai Payku dan rasakan semua keuntungannya dalam satu genggaman.',
      'skip': false
    },
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (int page) {
                setState(() {
                  _activePage = page;
                });
              },
              itemBuilder: (BuildContext context, int index) {
                return IntroWidget(
                  color: _pages[index]['color'],
                  title: _pages[index]['title'],
                  description: _pages[index]['description'],
                  image: _pages[index]['image'],
                  skip: _pages[index]['skip'],
                  onTab: onNextPage,
                  onSkip: onSkip,
                );
              }),
          Positioned(
            top: MediaQuery.of(context).size.height / 1.75,
            right: 0,
            left: 0,
            child: Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildIndicator())
              ],
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildIndicator() {
    final indicators = <Widget>[];

    for (var i = 0; i < _pages.length; i++) {
      if (_activePage == i) {
        indicators.add(_indicatorsTrue());
      } else {
        indicators.add(_indicatorsFalse());
      }
    }
    return indicators;
  }

  Widget _indicatorsTrue() {
    final String color;
    if (_activePage == 0) {
      color = '#fdc759';
    } else if (_activePage == 1) {
      color = '#fdc759';
    } else {
      color = '#fdc759';
    }

    return AnimatedContainer(
      duration: const Duration(microseconds: 300),
      height: 6,
      width: 42,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: hexToColor(color),
      ),
    );
  }

  Widget _indicatorsFalse() {
    return AnimatedContainer(
      duration: const Duration(microseconds: 300),
      height: 8,
      width: 8,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.grey.shade100,
      ),
    );
  }
}
