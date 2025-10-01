
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

 
import 'package:http/http.dart' as http;
import 'package:mobile/Products/seepays/layout/carouselDepan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:intl/intl.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/component/rewards.dart';
 
import 'package:mobile/screen/profile/cs/cs.dart';
import 'package:mobile/screen/transfer_saldo/transfer_saldo.dart';
import '../../../component/card_info.dart';
 
 

 
 
import '../../seepays/layout/menudepan.dart';
import 'package:mobile/utils/debug_helper.dart';
 

class CarouselBannerAPI extends StatefulWidget {
  const CarouselBannerAPI({Key key}) : super(key: key);

  @override
  State<CarouselBannerAPI> createState() => _CarouselBannerAPIState();
}

class _CarouselBannerAPIState extends State<CarouselBannerAPI> {
  List<dynamic> banners = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBanner();
  }

  Future<void> fetchBanner() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');  
      DebugHelper.debugPrint('DEBUG TOKEN: $token');
      if (token == null || token.isEmpty) {
        setState(() {
          isLoading = false;
        });
        DebugHelper.debugPrint('Token null/kosong!');
        return;
      }

      final response = await http.get(
        Uri.parse('https://app.payuni.co.id/api/v1/banner/list?limit=3'),
        headers: {'Authorization': token},
      );

      DebugHelper.debugPrint('DEBUG STATUS: ${response.statusCode}');
      DebugHelper.debugPrint('DEBUG BODY: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResp = json.decode(response.body);
        setState(() {
          banners = jsonResp['data'] ?? [];
          isLoading = false;
        });
        DebugHelper.debugPrint('DEBUG BANNERS: $banners');
      } else {
        setState(() {
          isLoading = false;
        });
        DebugHelper.debugPrint('Response status bukan 200');
      }
    } catch (e) {
      DebugHelper.debugPrint('DEBUG ERROR: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final bool isSmallScreen = screenWidth < 360;
    final bool isMediumScreen = screenWidth >= 360 && screenWidth < 414;
    
    // Responsive carousel dimensions
    final double carouselHeight = isSmallScreen ? 90 : (isMediumScreen ? 100 : 110);
    final double viewportFraction = isSmallScreen ? 0.88 : (isMediumScreen ? 0.90 : 0.92);
    final double aspectRatio = isSmallScreen ? 3.2 : (isMediumScreen ? 3.1 : 3.0);
    
    DebugHelper.debugPrint('DEBUG isLoading: $isLoading');
    DebugHelper.debugPrint('DEBUG banners: $banners');
    if (isLoading) {
      return Container(
        height: carouselHeight,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (banners.isEmpty) {
      return Container(
        height: carouselHeight,
        child: Center(child: Text('Banner Not Found ', style: TextStyle(color: Colors.grey))),
      );
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: carouselHeight,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: viewportFraction,
        aspectRatio: aspectRatio,
      ),
      items: banners.map((banner) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
           
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 2 : 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12, 
                      blurRadius: isSmallScreen ? 6 : 8, 
                      offset: Offset(0, isSmallScreen ? 2 : 3),
                    ),
                  ],
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        banner['cover'],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[200],
                          child: Center(child: Icon(Icons.broken_image)),
                        ),
                        loadingBuilder: (ctx, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(child: CircularProgressIndicator());
                        },
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          width: double.infinity,
                          color: Colors.black.withOpacity(0.24),
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 8 : 10, 
                            vertical: isSmallScreen ? 3 : 4
                          ),
                          child: Text(
                            banner['title'] ?? '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 11 : (isMediumScreen ? 12 : 13),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

// Home2App class
class Home2App extends StatefulWidget {
  @override
  _Home2AppState createState() => _Home2AppState();
}

class _Home2AppState extends State<Home2App> with SingleTickerProviderStateMixin {
  AnimationController animationController;
 final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  // Function to handle refresh
  Future<void> _onRefresh() async {
    try {
      DebugHelper.debugPrint('🔄 Starting refresh process...');
      
      // Clear all caches first
      await _clearAllCaches();
      
      // Refresh banner data by triggering rebuild
      setState(() {
        // This will trigger rebuild of all components
        // The components will automatically fetch fresh data due to cache clearing
      });
      
      // Add a small delay to show refresh animation
      await Future.delayed(Duration(milliseconds: 800));
      
      DebugHelper.debugPrint('✅ Refresh process completed');
      
    } catch (e) {
      DebugHelper.debugPrint('❌ Error during refresh: $e');
    }
  }

  // Method to clear all caches
  Future<void> _clearAllCaches() async {
    try {
      DebugHelper.debugPrint('🧹 Clearing all caches...');
      
      // Clear MenuDepan cache
      // MenuDepan.clearCache(); // This will be called through the widget rebuild
      
      // Clear HTTP cache
      await DefaultCacheManager().emptyCache();
      
      // Clear SharedPreferences cache if needed
      // final prefs = await SharedPreferences.getInstance();
      // prefs.remove('cached_data_key');
      
      DebugHelper.debugPrint('✅ All caches cleared successfully');
    } catch (e) {
      DebugHelper.debugPrint('❌ Error clearing caches: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final double screenAspectRatio = screenWidth / screenHeight;
    
    // Responsive calculations based on screen size
    final bool isSmallScreen = screenWidth < 360;
    final bool isMediumScreen = screenWidth >= 360 && screenWidth < 414;
    final bool isLargeScreen = screenWidth >= 414;
    
    // Responsive dimensions
    final double headerHeight = isSmallScreen ? 200 : (isMediumScreen ? 220 : 240);
    final double saldoCardTop = isSmallScreen ? 120 : (isMediumScreen ? 130 : 140);
    final double saldoCardHeight = isSmallScreen ? 100 : (isMediumScreen ? 110 : 120);
    final double floatingGap = isSmallScreen ? 15 : 20;
    final double floatingCardTop = saldoCardTop + saldoCardHeight + floatingGap;

    return Scaffold(
      backgroundColor: Color(0xFFF6F7FB),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _onRefresh,
        color: Color(0xFFA259FF),
        backgroundColor: Colors.white,
        strokeWidth: 3.0,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Stack(
            children: <Widget>[
                          // HEADER GRADIENT D SHAPE - RESPONSIVE
              Positioned(
                top: isSmallScreen ? 20 : 30,
                left: isSmallScreen ? -100 : -120,
                right: isSmallScreen ? -5 : -10,
                child: Center(
                  child: Container(
                    width: isSmallScreen ? screenWidth * 2.2 : (isMediumScreen ? screenWidth * 2.0 : 830),
                    height: isSmallScreen ? 280 : (isMediumScreen ? 310 : 340),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0),
                        bottomLeft: Radius.circular(isSmallScreen ? 15 : 20),
                        topRight: Radius.elliptical(
                          isSmallScreen ? 400 : (isMediumScreen ? 500 : 600), 
                          isSmallScreen ? 150 : (isMediumScreen ? 175 : 200)
                        ),
                        bottomRight: Radius.circular(0),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFA259FF),    
                          Color(0xFF8B4BCF),   
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ),
   

              // TITLE TEXT - SEEPAYS AND POINT - RESPONSIVE
              Positioned(
                top: isSmallScreen ? 40 : (isMediumScreen ? 45 : 50),
                left: 0,
                child: Padding(
                  padding: EdgeInsets.only(left: isSmallScreen ? 8 : 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SEEPAY",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 26 : (isMediumScreen ? 29 : 32),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 2 : 4),
                      Text(
                        "Point: ${bloc.poin.valueWrapper?.value ?? 0}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 14 : (isMediumScreen ? 15 : 16),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // APP LOGO - TOP RIGHT - RESPONSIVE
              Positioned(
                top: isSmallScreen ? 25 : (isMediumScreen ? 27 : 30),
                right: isSmallScreen ? 15 : 20,
                child: Container(
                  width: isSmallScreen ? 65 : (isMediumScreen ? 72 : 80),
                  height: isSmallScreen ? 65 : (isMediumScreen ? 72 : 80),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                    child: Image.asset(
                      'assets/seepaysicon.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                          ),
                          child: Icon(
                            Icons.apps,
                            color: Colors.white,
                            size: isSmallScreen ? 24 : (isMediumScreen ? 27 : 30),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // SALDO CARD DI HEADER - RESPONSIVE
              Positioned(
                top: saldoCardTop,
                left: isSmallScreen ? 30 : (isMediumScreen ? 35 : 40),
                right: isSmallScreen ? 60 : (isMediumScreen ? 70 : 80),
                child: Container(
                  height: saldoCardHeight,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 15 : (isMediumScreen ? 18 : 20), 
                    vertical: isSmallScreen ? 8 : 10
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.11),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 15 : 18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: isSmallScreen ? 2 : 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Saldo",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 13 : (isMediumScreen ? 14 : 15)
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 2 : 3),
                            Text(
                              "Rp ${NumberFormat.decimalPattern('id').format(bloc.saldo.valueWrapper?.value ?? 0)}",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 18 : (isMediumScreen ? 20 : 22),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 8 : 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/topup');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[700],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 20 : (isMediumScreen ? 23 : 26), 
                            vertical: isSmallScreen ? 8 : 10
                          ),
                        ),
                        child: Text(
                          "Topup",
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : (isMediumScreen ? 13 : 14), 
                            color: Colors.white
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

            //  SizedBox(height: 20),

              // FLOATING MENU CARD, RAPAT DENGAN SALDO - RESPONSIVE
              Positioned(
                top: floatingCardTop,
                left: isSmallScreen ? 20 : (isMediumScreen ? 23 : 26),
                right: isSmallScreen ? 25 : (isMediumScreen ? 27 : 30),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 18 : (isMediumScreen ? 20 : 22), 
                    horizontal: isSmallScreen ? 8 : 12
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: isSmallScreen ? 12 : 16,
                        offset: Offset(0, isSmallScreen ? 4 : 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MenuImageItem(
                        image: 'assets/img/money.png',
                        label: 'Hadiah',
                        color: Colors.purple,
                        isSmallScreen: isSmallScreen,
                        isMediumScreen: isMediumScreen,
                        onTap: () => Navigator.of(context).pushNamed('/rewards'),
                      ),
                      _MenuImageItem(
                        image: 'assets/commist.png',
                        label: 'Komisi',
                        color: Colors.purple,
                        isSmallScreen: isSmallScreen,
                        isMediumScreen: isMediumScreen,
                        onTap: () => Navigator.of(context).pushNamed('/komisi'),
                      ),
                      _MenuImageItem(
                        image: 'assets/img/next.png',
                        label: 'Transfer',
                        color: Colors.purple,
                        isSmallScreen: isSmallScreen,
                        isMediumScreen: isMediumScreen,
                        onTap: () {
                          Navigator.of(context).push(PageTransition(
                            child: TransferSaldo(''),
                            type: PageTransitionType.rippleRightUp,
                            duration: Duration(milliseconds: 500),
                          ));
                        },
                      ),
                      _MenuImageItem(
                        image: 'assets/img/people.png',
                        label: 'Bantuan',
                        color: Colors.purple,
                        isSmallScreen: isSmallScreen,
                        isMediumScreen: isMediumScreen,
                        onTap: () {
                          Navigator.of(context).push(PageTransition(
                            child: CS(),
                            type: PageTransitionType.rippleRightUp,
                            duration: Duration(milliseconds: 500),
                          ));
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // MAIN CONTENT - RESPONSIVE
            Column(
      children: [
        // Bagian Atas dengan Padding
        Container(
          margin: EdgeInsets.only(top: floatingCardTop + (isSmallScreen ? 80 : (isMediumScreen ? 85 : 90))),
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 15 : (isMediumScreen ? 16 : 18), 
            vertical: 2
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: isSmallScreen ? 50 : (isMediumScreen ? 55 : 60)),
            //  SectionTitle(title: 'Produk'),
               
              MenuDepan(
                grid: isSmallScreen ? 4 : (isMediumScreen ? 4 : 5), 
                gradient: true
              ),
              // /SizedBox(height: 8),
          CarouselDepan(), 
            ],
          ),
        ),

        

        SizedBox(height: isSmallScreen ? 30 : (isMediumScreen ? 35 : 40)),

         
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 15 : (isMediumScreen ? 16 : 18)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SectionTitle(
                title: 'Info ',
                isSmallScreen: isSmallScreen,
                isMediumScreen: isMediumScreen,
              ),
              Text(
                'Mengenal Lebih Jauh Aplikasi ${configAppBloc.namaApp.valueWrapper?.value}',
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : (isMediumScreen ? 13 : 14), 
                  color: Colors.black54
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isSmallScreen ? 8 : 10),
              
              CardInfo(),
              SizedBox(height: isSmallScreen ? 15 : 20),
              SectionTitle(
                title: 'Hadiah Unggulan',
                isSmallScreen: isSmallScreen,
                isMediumScreen: isMediumScreen,
              ),
              SizedBox(height: isSmallScreen ? 2 : 4),
              Text(
                'Reward Akan Di Berikan Ke Member ${configAppBloc.namaApp.valueWrapper?.value}',
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : (isMediumScreen ? 13 : 14), 
                  color: Colors.black54
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isSmallScreen ? 10 : 14),
              RewardComponent(),
              SizedBox(height: isSmallScreen ? 30 : 38),
            ],
          ),
        ),
      ],
    )
            ],
          ),
        ),
      ),
    );
  }
}

// --------- Icon Berbasis Image Asset ---------
class _MenuImageItem extends StatelessWidget {
  final String image;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isSmallScreen;
  final bool isMediumScreen;

  const _MenuImageItem({
    Key key,
    @required this.image,
    @required this.label,
    this.color = Colors.green,
    @required this.onTap,
    this.isSmallScreen = false,
    this.isMediumScreen = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double containerSize = isSmallScreen ? 45 : (isMediumScreen ? 49 : 54);
    final double padding = isSmallScreen ? 10.0 : (isMediumScreen ? 11.0 : 12.0);
    final double spacing = isSmallScreen ? 5 : 7;
    final double fontSize = isSmallScreen ? 10 : (isMediumScreen ? 11 : 12);
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: containerSize,
            height: containerSize,
            decoration: BoxDecoration(
              color: color.withOpacity(0.13),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Image.asset(
                image,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: spacing),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              color: color,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final bool isSmallScreen;
  final bool isMediumScreen;
  
  const SectionTitle({
    Key key, 
    @required this.title,
    this.isSmallScreen = false,
    this.isMediumScreen = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double fontSize = isSmallScreen ? 20 : (isMediumScreen ? 22 : 25);
    final double leftPadding = isSmallScreen ? 20 : (isMediumScreen ? 22 : 25);
    
    return Padding(
      padding: EdgeInsets.only(left: leftPadding, bottom: 3),
      child: Text(
        title,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w300,
          color: Colors.black87,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}