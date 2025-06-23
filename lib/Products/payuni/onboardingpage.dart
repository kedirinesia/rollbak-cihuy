import 'package:flutter/material.dart';
import '../../screen/login.dart';
 

 

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _pageIndex = 0;

  final List<Map<String, String>> pages = [
    {
      "image": "https://dokumen.payuni.co.id/logo/mykonter/custom/splascreen1.png",
      "title": "Semua Layanan PPOB\ndalam Satu Aplikasi",
      "desc": "Bayar tagihan Listrik, Pulsa, Paket data, PDAM, BPJS dan banyak lagi.",
      "btn": "Mulai Sekarang"
    },
    {
      "image": "https://dokumen.payuni.co.id/logo/mykonter/custom/splasscreen2.png",
      "title": "Tambah Penghasilan\ndari Rumah",
      "desc": "Dapatkan komisi dari setiap transaksi. Cocok untuk konter dan bisnis rumahan.",
      "btn": "Lanjutkan"
    },
    {
      "image": "https://dokumen.payuni.co.id/logo/mykonter/custom/splasscreen3.png",
      "title": "Riwayat & Laporan\nTransaksi Lengkap",
      "desc": "Lihat semua Transaksi dan Laporan Keuangan harian anda secara Real-Time.",
      "btn": "Lanjutkan"
    },
  ];

  void nextPage() {
    if (_pageIndex < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.ease,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) =>  LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF07aba0);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar custom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
              child: Row(
                children: List.generate(
                  pages.length,
                  (idx) => Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.only(right: idx < pages.length - 1 ? 8 : 0),
                      height: 6,
                      decoration: BoxDecoration(
                        color: _pageIndex == idx ? primaryColor : const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (index) => setState(() => _pageIndex = index),
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Judul
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          pages[i]["title"]!,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Deskripsi
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          pages[i]["desc"]!,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color(0xFF707070),
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Gambar di bawah deskripsi
                      Image.network(
                        pages[i]["image"]!,
                        height: screenWidth * 0.9,
                        fit: BoxFit.contain,
                      ),
                      const Spacer(),
                      // Tombol
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                pages[i]['btn']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, color: Colors.white, size: 21),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
