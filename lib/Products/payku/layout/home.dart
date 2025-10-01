
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/Products/payku/layout/components/dashboard_panel.dart';
import 'package:mobile/Products/payku/layout/qris.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/Products/payku/layout/reward.dart';
import 'package:mobile/Products/payku/layout/components/sticky_navbar.dart';
import 'package:mobile/Products/payku/layout/components/carousel_header.dart';
import 'package:mobile/Products/payku/layout/components/menu_depan.dart';
import 'package:mobile/screen/kyc/reject.dart';
import 'package:mobile/screen/kyc/verification1.dart';
import 'package:mobile/screen/kyc/waiting.dart';
import 'package:mobile/screen/profile/invite/invite.dart';
import 'package:mobile/component/card_info.dart';
import 'package:mobile/modules.dart';
import 'package:http/http.dart' as http;

class HomePayku extends StatefulWidget {
  @override
  _HomePaykuState createState() => _HomePaykuState();
}

class _HomePaykuState extends State<HomePayku> {
  bool loading = true;
  bool isTransparent = true;

  @override
  void initState() {
    super.initState();
  }

  void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 5,
                color: Colors.green,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
                backgroundColor: Colors.grey[200],
              ),
            ),
          ),
        );
      },
    );
  }

  void hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    final response = await http.get(
      Uri.parse('$apiUrl/user/info'),
      headers: {'Authorization': bloc.token.valueWrapper?.value},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user info');
    }
  }

  void _onVerificationButtonPressed(BuildContext context) async {
    showLoading(context);

    try {
      Map<String, dynamic> userInfo = await getUserInfo();
      Map<String, dynamic> kyc = userInfo['data']['kyc'];

      hideLoading(context);

      if (kyc == null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SubmitKyc1()),
        );
      } else {
        switch (kyc['status']) {
          case 0: // Dalam Proses
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WaitingKycPage()),
            );
            break;
          case 1: // Sukses
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyQrisPage()),
            );
            break;
          case 2: // Di Tolak
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => KycRejectPage()),
            );
            break;
          default:
            break;
        }
      }
    } catch (error) {
      hideLoading(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final bool isSmallScreen = screenWidth < 360;
    final bool isMediumScreen = screenWidth >= 360 && screenWidth < 414;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(.15),
        toolbarHeight: 0.0,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(Duration(milliseconds: 500));
          await updateUserInfo();
          setState(() {});
        },
        child: Column(
          children: [
            SafeArea(
                maintainBottomViewPadding: true,
                child: StickyNavBar(isTransparent: false)),
            Container(
              color: Colors.white,
              child: Container(
                padding: EdgeInsets.all(isSmallScreen ? 12 : (isMediumScreen ? 13 : 15)),
                color: Theme.of(context).primaryColor.withOpacity(.15),
                child: DashboardPanel(),
              ),
            ),
            Container(
              color: Colors.white,
              child: Container(
                color: Theme.of(context).primaryColor.withOpacity(.15),
                child: Container(
                  width: double.infinity,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    bloc.user.valueWrapper?.value.kyc_verification
                        ? SizedBox()
                        : Container(
                            margin: EdgeInsets.only(
                                right: isSmallScreen ? 12.0 : (isMediumScreen ? 13.0 : 15.0),
                                left: isSmallScreen ? 12.0 : (isMediumScreen ? 13.0 : 15.0),
                                bottom: isSmallScreen ? 12.0 : 15.0,
                                top: isSmallScreen ? 3.0 : 5.0),
                            height: isSmallScreen ? 90 : (isMediumScreen ? 95 : 100),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(isSmallScreen ? 4 : 5),
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0x3f000000).withOpacity(0.2),
                                    offset: Offset(0, 0),
                                    blurRadius: isSmallScreen ? 4 : 5)
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: isSmallScreen ? 8.0 : 10.0, 
                                  left: isSmallScreen ? 15.0 : (isMediumScreen ? 17.0 : 20.0), 
                                  right: isSmallScreen ? 15.0 : (isMediumScreen ? 17.0 : 20.0)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Upgrade ke Akun Premium! Nikmatin Layanan QRIS Toko",
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 10 : (isMediumScreen ? 11 : 12),
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xff000000),
                                    ),
                                  ),
                                  SizedBox(height: isSmallScreen ? 3 : 5),
                                  Row(
                                    children: [
                                      Icon(Icons.check_box,
                                          color: Color(0xff79B4CD), size: isSmallScreen ? 10 : (isMediumScreen ? 11 : 12)),
                                      SizedBox(width: isSmallScreen ? 2 : 3),
                                      Text(
                                        "Realtime Coy",
                                        style: TextStyle(fontSize: isSmallScreen ? 9 : (isMediumScreen ? 10 : 11)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.check_box,
                                          color: Color(0xff79B4CD), size: isSmallScreen ? 10 : (isMediumScreen ? 11 : 12)),
                                      SizedBox(width: isSmallScreen ? 2 : 3),
                                      Text(
                                        "Biaya Admin 0,8%",
                                        style: TextStyle(fontSize: isSmallScreen ? 9 : (isMediumScreen ? 10 : 11)),
                                      ),
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _onVerificationButtonPressed(context),
                                      style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                  Theme.of(context)
                                                      .primaryColor),
                                          shape: WidgetStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                          minimumSize:
                                              WidgetStateProperty.all<Size>(
                                                  Size(0, 25))),
                                      child: Text(
                                        "Upgrade",
                                        style: TextStyle(
                                            fontSize: isSmallScreen ? 10 : (isMediumScreen ? 11 : 12),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    MenuComponent(),
                    ColoredBox(
                      color: Colors.grey.shade200,
                      child: SizedBox(
                        width: double.infinity,
                        height: 10,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 20.0),
                      child: ListTile(
                        title: Text('Selalu Ada di Payku',
                            style: TextStyle(
                                fontSize: isSmallScreen ? 11.0 : (isMediumScreen ? 12.0 : 13.0), fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            'Mudah Dapatkan Akses Info Promo Terbaru',
                            style: TextStyle(
                                fontSize: isSmallScreen ? 9.0 : (isMediumScreen ? 10.0 : 11.0), color: Colors.grey[500])),
                      ),
                    ),
                    Container(
                      height: isSmallScreen ? 130 : (isMediumScreen ? 140 : 150),
                      margin: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 12 : (isMediumScreen ? 13 : 15),
                      ),
                      child: CarouselHeader(),
                    ),
                    ColoredBox(
                      color: Colors.grey.shade200,
                      child: SizedBox(
                        width: double.infinity,
                        height: 10,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 20),
                      child: ListTile(
                        title: Text('Info Menarik dari Payku',
                            style: TextStyle(
                                fontSize: isSmallScreen ? 11.0 : (isMediumScreen ? 12.0 : 13.0), fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            'Baca Info Supaya Tidak Ketinggalan Kebahagiaan',
                            style: TextStyle(
                                fontSize: isSmallScreen ? 9.0 : (isMediumScreen ? 10.0 : 11.0), color: Colors.grey[500])),
                      ),
                    ),
                    CardInfo(),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(
                        left: isSmallScreen ? 8.0 : (isMediumScreen ? 9.0 : 10.0), 
                        right: isSmallScreen ? 8.0 : (isMediumScreen ? 9.0 : 10.0)
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 15.0 : (isMediumScreen ? 17.0 : 20.0), 
                          vertical: isSmallScreen ? 15.0 : (isMediumScreen ? 17.0 : 20.0)),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColor.withOpacity(.75),
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColor.withOpacity(.5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(isSmallScreen ? 12.0 : 15.0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Dapatkan Komisi dari Ajak Teman Kamu',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmallScreen ? 13.0 : (isMediumScreen ? 14.0 : 15.0))),
                          SizedBox(height: isSmallScreen ? 8.0 : 10.0),
                          Text(
                              'Mengajak Teman Kamu Untuk Menggunakan Payku adalah Salah Satu Cara Untuk Mendapatkan Penghasilan Tambahan Buat Kamu',
                              style: TextStyle(
                                  fontSize: isSmallScreen ? 10.0 : (isMediumScreen ? 11.0 : 12.0), color: Colors.grey[200])),
                          SizedBox(height: isSmallScreen ? 8.0 : 10.0),
                          InkWell(
                              onTap: () {
                                return Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => InvitePage()));
                              },
                              highlightColor: Colors.black.withOpacity(.4),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 15.0 : (isMediumScreen ? 17.0 : 20.0), 
                                    vertical: isSmallScreen ? 8.0 : 10.0),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.white, width: 1.0),
                                    borderRadius: BorderRadius.circular(isSmallScreen ? 12.0 : 15.0)),
                                child: Text('Undang Teman',
                                    style: TextStyle(
                                        fontSize: isSmallScreen ? 10.0 : (isMediumScreen ? 11.0 : 12.0), color: Colors.white)),
                              ))
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    ColoredBox(
                      color: Colors.grey.shade200,
                      child: SizedBox(
                        width: double.infinity,
                        height: 10,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 20),
                      child: ListTile(
                        title: Text('Dapat Hadiah dari Payku',
                            style: TextStyle(
                                fontSize: isSmallScreen ? 11.0 : (isMediumScreen ? 12.0 : 13.0), fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            'Kumpulkan Poin Kamu dan Tukarkan dengan Reward yang Tersedia Dari Payku',
                            style: TextStyle(
                                fontSize: isSmallScreen ? 9.0 : (isMediumScreen ? 10.0 : 11.0), color: Colors.grey[500])),
                      ),
                    ),
                    RewardComponent(),
                    SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
