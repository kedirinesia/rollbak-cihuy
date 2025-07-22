import 'package:flutter/material.dart';
import 'package:mobile/Products/mykonterr/layout/login.dart';

class OnBoardingScreen extends StatefulWidget {
  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'icon': 'https://dokumen.payuni.co.id/logo/mykonter/custom/splascreen1.png',
      'title': 'Semua Layanan PPOB\ndalam Satu Aplikasi',
      'desc': 'Bayar tagihan Listrik, Pulsa, Paket data, PDAM,\nBPJS dan banyak lagi.'
    },
    {
      'icon': 'https://dokumen.payuni.co.id/logo/mykonter/custom/splasscreen2.png',
      'title': 'Tambah Penghasilan dari Rumah',
      'desc': 'Dapatkan komisi dari setiap transaksi. Cocok untuk konter dan bisnis rumahan.'
    },
    {
      'icon': 'https://dokumen.payuni.co.id/logo/mykonter/custom/splasscreen3.png',
      'title': 'Riwayat & Laporan Transaksi Lengkap',
      'desc': 'Lihat semua Transaksi dan Laporan Keuangan harian anda secara Real-Time.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(onboardingData.length, (i) => AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 4),
              height: 4,
              width: (screenWidth / onboardingData.length) - 32,
              decoration: BoxDecoration(
                color: i == _currentPage ? Theme.of(context).primaryColor : Theme.of(context).secondaryHeaderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            )),
          ),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: onboardingData.length,
              itemBuilder: (_, index) {
                final item = onboardingData[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 40),
                      Text(
                        item['title']!,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        item['desc']!,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.06),
                      Expanded(
                        child: Center(
                          child: Image.network(
                            item['icon']!,
                            height: screenHeight * 0.35,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton.icon(
              onPressed: () {
                if (_currentPage == onboardingData.length - 1) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
                } else {
                  _controller.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
                }
              },
              icon: Icon(Icons.arrow_forward),
              label: Text(_currentPage == 0
                ? 'Lanjutkan'
                : (_currentPage == onboardingData.length - 1
                    ? 'Mulai Sekarang'
                    : 'Lanjutkan')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          )
        ],
      ),
    );
  }
}