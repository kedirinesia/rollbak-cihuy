// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marquee/marquee.dart';
import 'package:mobile/Products/xenaja/layout/components/menuTool.dart';
import 'package:mobile/Products/xenaja/layout/profile.dart';
import 'package:mobile/Products/xenaja/layout/qris.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/component/card_info.dart';
import 'package:mobile/component/carousel-depan.dart';
import 'package:mobile/Products/xenaja/layout/components/menudepan.dart';
import 'package:mobile/component/rewards.dart';
import 'package:mobile/models/count_trx.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/history/history.dart';
import 'package:mobile/Products/xenaja/layout/invite/main.dart';
import 'package:mobile/screen/kyc/reject.dart';
import 'package:mobile/screen/kyc/verification1.dart';
import 'package:mobile/screen/kyc/waiting.dart';
import 'package:mobile/screen/profile/reward/list_reward.dart';
import 'package:mobile/screen/transfer_saldo/transfer_by_qr.dart';

import 'package:mobile/screen/marketplace/index.dart';
import 'package:mobile/provider/analitycs.dart' show analitycs;

class HomePopay extends StatefulWidget {
  @override
  _HomePopayState createState() => _HomePopayState();
}

class _HomePopayState extends State<HomePopay> with TickerProviderStateMixin {
  CountTrx _countTrx;
  int pageIndex = 0;
  UserModel user;
  bool loading = true;
  AnimationController _rotationController;
  List<Widget> halaman = [
    Container(),
    HistoryPage(),
    ListReward(),
    ProfilePopay()
  ];

  @override
  void initState() {
    _getTrxCount();
    super.initState();
    analitycs.pageView(
        '/home', {'userId': bloc.userId.valueWrapper?.value, 'title': 'Home'});
    _rotationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
  }

  // void getData() async {
  //   http.Response response = await http.get(Uri.parse('$apiUrl/user/info'),
  //       headers: {'Authorization': bloc.token.valueWrapper?.value});

  //   if (response.statusCode == 200) {
  //     user = UserModel.fromJson(json.decode(response.body)['data']);
  //     setState(() {
  //       loading = false;
  //     });
  //   }
  // }

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

  Future<void> _getTrxCount() async {
    try {
      http.Response response = await http.get(
        Uri.parse('$apiUrl/trx/countTransaction'),
        headers: {
          'Authorization': bloc.token.valueWrapper?.value ?? '',
        },
      );

      if (response.statusCode == 200) {
        CountTrx trxData =
            CountTrx.fromJson(json.decode(response.body)['data']);
        bloc.todayTrxCount.add(trxData);

        setState(() {
          _countTrx = trxData;
        });
      } else {
        String message = json.decode(response.body)['message'] ??
            'Terjadi kesalahan saat mengambil data';
        ScaffoldMessenger.of(context).showSnackBar(
          Alert(
            message,
            isError: true,
          ),
        );
      }
    } catch (e) {
      print('ERROR GET TRX COUNT: $e');
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
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: configAppBloc.isMarketplace.valueWrapper?.value
            ? Icon(Icons.shopping_cart_rounded)
            : CachedNetworkImage(
                imageUrl:
                    'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Fqr-code-scan%20(1).png?alt=media&token=9c6c8655-238f-4c93-9b1e-f5176a7d1dcb'),
        elevation: 0.0,
        onPressed: () async {
          if (configAppBloc.isMarketplace.valueWrapper?.value) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => MarketPage()));
          } else {
            var barcode = await BarcodeScanner.scan();
            if (barcode.rawContent.isNotEmpty) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => TransferByQR(barcode.rawContent)));
            }
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: pageIndex == 0
          ? CustomScrollView(
              slivers: <Widget>[
                SliverPersistentHeader(
                  pinned: true,
                  delegate: MySliverAppBar(
                    expandedHeight: 258.0,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                    ),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 28,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xffEADEE9),
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x33333333),
                                offset: Offset(0, 4),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 8),
                                padding: EdgeInsets.only(left: 8),
                                child: Icon(Icons.volume_up_rounded),
                              ),
                              Expanded(
                                child: Marquee(
                                  text: configAppBloc.info.valueWrapper.value
                                                  .marquee !=
                                              null &&
                                          configAppBloc.info.valueWrapper.value
                                                  .marquee.message !=
                                              null
                                      ? configAppBloc.info.valueWrapper.value
                                          .marquee.message
                                      : 'SEPUTAR INFO : Selalu waspada terhadap segala bentuk PENIPUAN, pihak kami tidak pernah telp / meminta kode OTP apapun. Biasakan SAVE kontak kami 08980000073 atau bisa ke LIVECHAT',
                                  style: TextStyle(color: Colors.black),
                                  blankSpace: 100,
                                ),
                              )
                            ],
                          ),
                        ),
                        bloc.user.valueWrapper?.value.kyc_verification
                            ? SizedBox(height: 16)
                            : Container(
                                height: 133,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/img/payku/aktivasiQris.png'),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x33333333),
                                      offset: Offset(0, 4),
                                      blurRadius: 2.5,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(top: 20, left: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Layanan QRIS Toko",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xff000000),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.check_box,
                                              color: Color(0xff79B4CD),
                                              size: 12),
                                          SizedBox(width: 3),
                                          Text(
                                            "Realtime Coy",
                                            style: TextStyle(fontSize: 11),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.check_box,
                                              color: Color(0xff79B4CD),
                                              size: 12),
                                          SizedBox(width: 3),
                                          Text(
                                            "Biaya Admin 0",
                                            style: TextStyle(fontSize: 11),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            _onVerificationButtonPressed(
                                                context),
                                        // onPressed: () =>
                                        //     Navigator.of(context).pushReplacement(
                                        //   MaterialPageRoute(
                                        //     builder: (_) => SubmitKyc1(),
                                        //   ),
                                        // ),
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                            Color(0xff945a90),
                                          ),
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                          ),
                                        ),
                                        child: Text("AKTIVASI SEKARANG"),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        // SizedBox(height: 20),
                        Container(
                          margin: EdgeInsets.only(right: 20.0),
                          child: ListTile(
                            contentPadding: EdgeInsets.only(left: 0),
                            title: Text('Menu Transaksi',
                                style: TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text('Banyak Promo & Pastinya Murah',
                                style: TextStyle(
                                    fontSize: 11.0, color: Colors.grey[500])),
                          ),
                        ),
                        MenuDepan(grid: 5, baris: 2, radius: 10.0),
                        // SizedBox(height: 20),
                        Container(
                          margin: EdgeInsets.only(right: 20.0),
                          child: ListTile(
                            contentPadding: EdgeInsets.only(left: 0),
                            title: Text('XenAja Service',
                                style: TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                'Banyak Fitur Tersedia & Reward Menarik',
                                style: TextStyle(
                                    fontSize: 11.0, color: Colors.grey[500])),
                          ),
                        ),
                        // SizedBox(height: 10),
                        Container(
                          child: Row(
                            children: <Widget>[
                              Flexible(
                                flex: 1,
                                child: Column(
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () =>
                                          _onVerificationButtonPressed(context),
                                      child: Container(
                                        height: 115,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Color(0x3f000000),
                                                offset: Offset(0, 4),
                                                blurRadius: 2)
                                          ],
                                        ),
                                        child: Stack(
                                          children: [
                                            Container(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 12, right: 12),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "QRIS Feature",
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Color(
                                                                    0xff000000),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 20),
                                                            Container(
                                                              constraints:
                                                                  BoxConstraints(
                                                                maxWidth: 55,
                                                              ),
                                                              child: Text(
                                                                "Fitur QRIS exclusive untuk Mitra XenAja",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                  color: Color(
                                                                      0xffaaaaaa),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .arrow_forward_ios_rounded,
                                                              color: Color(
                                                                  0XFF945A90),
                                                              size: 12,
                                                            ),
                                                            SizedBox(
                                                                height: 20),
                                                            Container(
                                                              width: 46,
                                                              height: 46,
                                                              child: Image.asset(
                                                                  'assets/img/payku/qrcode.png'),
                                                            )
                                                          ],
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          pageIndex = 2;
                                        });
                                      },
                                      child: Container(
                                        height: 115,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Color(0x3f000000),
                                                offset: Offset(0, 4),
                                                blurRadius: 2)
                                          ],
                                        ),
                                        child: Stack(
                                          children: [
                                            Container(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 12, right: 12),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "Rewards",
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Color(
                                                                    0xff000000),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 20),
                                                            Container(
                                                              constraints:
                                                                  BoxConstraints(
                                                                      maxWidth:
                                                                          55),
                                                              child: Text(
                                                                "Dapatkan Rewards Setiap Transaksi",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w300,
                                                                    color: Color(
                                                                        0xffaaaaaa)),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .arrow_forward_ios_rounded,
                                                              size: 12,
                                                              color: Color(
                                                                  0XFF945A90),
                                                            ),
                                                            SizedBox(
                                                                height: 20),
                                                            Container(
                                                              width: 46,
                                                              height: 46,
                                                              child: Image.asset(
                                                                  'assets/img/payku/gift.png'),
                                                            )
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                flex: 1,
                                child: Container(
                                  height: 240,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Color(0x3f000000),
                                          offset: Offset(0, 4),
                                          blurRadius: 2)
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      Container(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 12, right: 12, top: 16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text(
                                                  "Top Up Center",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xff000000),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 9,
                                              ),
                                              Container(
                                                constraints: BoxConstraints(
                                                    maxWidth: 134),
                                                child: Text(
                                                  "Banyak layanan dan Banyak Penghasilan",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w300,
                                                    color: Color(0xffaaaaaa),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                child: TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pushNamed('/topup');
                                                  },
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(
                                                      Color(0xff945a90),
                                                    ),
                                                    shape: MaterialStateProperty
                                                        .all<
                                                            RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                    ),
                                                    minimumSize:
                                                        MaterialStateProperty
                                                            .all<Size>(
                                                      Size(64, 26),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    "TOP UP",
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Color(0xffffffff),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Divider(),
                                              SizedBox(height: 18),
                                              Container(
                                                child: Text(
                                                  "Top Up Terlaris",
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: Color(0xffaaaaaa)),
                                                ),
                                              ),
                                              SizedBox(height: 11),
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          right: 10),
                                                      height: 24,
                                                      width: 21,
                                                      child: Image.asset(
                                                          'assets/img/payku/pulsa.png'),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          right: 10),
                                                      height: 19,
                                                      width: 29,
                                                      child: Image.asset(
                                                          'assets/img/payku/game.png'),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          right: 10),
                                                      height: 22,
                                                      width: 15,
                                                      child: Image.asset(
                                                          'assets/img/payku/pln.png'),
                                                    ),
                                                    Container(
                                                      height: 24,
                                                      width: 24,
                                                      child: Image.asset(
                                                          'assets/img/payku/kuota.png'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 11),
                                              Container(
                                                constraints: BoxConstraints(
                                                  maxWidth: 147,
                                                ),
                                                child: Text(
                                                  "Dapatkan Poin Setiap Melakukan Pembelian Product",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w300,
                                                    color: Color(0xffaaaaaa),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 20.0),
                          child: ListTile(
                            contentPadding: EdgeInsets.only(left: 0),
                            title: Text('Selalu Ada di XenAja',
                                style: TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                'Mudah Dapatkan Akses Info Promo Terbaru',
                                style: TextStyle(
                                    fontSize: 11.0, color: Colors.grey[500])),
                          ),
                        ),
                        // SizedBox(height: 20),
                        CarouselDepan(),
                        // SizedBox(height: 20),
                        Container(
                          margin: EdgeInsets.only(right: 20),
                          child: ListTile(
                            contentPadding: EdgeInsets.only(left: 0),
                            title: Text('Info Menarik dari XenAja',
                                style: TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                'Baca Info Supaya Tidak Ketinggalan Kebahagiaan',
                                style: TextStyle(
                                    fontSize: 11.0, color: Colors.grey[500])),
                          ),
                        ),
                        CardInfo(),
                        Container(
                          // margin: EdgeInsets.only(left: 10.0, right: 10.0),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 20.0),
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(.6),
                              image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                      'https://dokumen.payuni.co.id/logo/xenaja/bghome.png'),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Dapatkan Komisi dari Ajak Teman Kamu',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0)),
                              SizedBox(height: 10.0),
                              Text(
                                  'Mengajak Teman Kamu Untuk Menggunakan XenAja adalah Salah Satu Cara Untuk Mendapatkan Penghasilan Tambahan Buat Kamu',
                                  style: TextStyle(
                                      fontSize: 12.0, color: Colors.grey[200])),
                              SizedBox(height: 10.0),
                              InkWell(
                                  onTap: () {
                                    return Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) => InvitePage()));
                                  },
                                  highlightColor: Colors.black.withOpacity(.4),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 10.0),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.white, width: 1.0)),
                                    child: Text('Undang Teman',
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.white)),
                                  ))
                            ],
                          ),
                        ),
                        // SizedBox(height: 20.0),
                        Container(
                          margin: EdgeInsets.only(right: 20),
                          child: ListTile(
                            contentPadding: EdgeInsets.only(left: 0),
                            title: Text('Dapat Hadiah dari XenAja',
                                style: TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                'Kumpulkan Poin Kamu dan Tukarkan dengan Reward yang Tersedia Dari XenAja',
                                style: TextStyle(
                                    fontSize: 11.0, color: Colors.grey[500])),
                          ),
                        ),
                        // SizedBox(height: 20.0),
                        RewardComponent(),
                        SizedBox(height: 50.0)
                      ],
                    ),
                  ),
                ),
              ],
            )
          : halaman[pageIndex],
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 50.0,
          padding: EdgeInsets.only(top: 10.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      pageIndex = 0;
                    });
                  },
                  child: Column(
                    children: <Widget>[
                      CachedNetworkImage(
                          imageUrl:
                              'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Fcombined_shape.png?alt=media&token=2d78122e-51a2-4a0b-9e6e-ed699b8a5758',
                          color: pageIndex == 0
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                          width: 20.0),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text('Home', style: TextStyle(fontSize: 10.0))
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      pageIndex = 1;
                    });
                  },
                  child: Column(
                    children: <Widget>[
                      CachedNetworkImage(
                          imageUrl:
                              'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Fhistory_inactive.png?alt=media&token=04704026-de7b-4dca-838f-ab5fdd6802be',
                          color: pageIndex == 1
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                          width: 20.0),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text('History', style: TextStyle(fontSize: 10.0))
                    ],
                  ),
                ),
              ),
              SizedBox(width: 40.0),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      pageIndex = 2;
                    });
                  },
                  child: Column(
                    children: <Widget>[
                      CachedNetworkImage(
                          imageUrl:
                              'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Flight-mode-home.png?alt=media&token=a42c10b4-8ae6-4c8e-b774-0056a4ca1e84',
                          color: pageIndex == 2
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                          width: 20.0),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text('Rewards', style: TextStyle(fontSize: 10.0))
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      pageIndex = 3;
                    });
                  },
                  child: Column(
                    children: <Widget>[
                      CachedNetworkImage(
                          imageUrl:
                              'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Fprofile-home.png?alt=media&token=65f46061-2ae6-48ba-8e61-dfddec73706f',
                          color: pageIndex == 3
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                          width: 20.0),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text('Profile', style: TextStyle(fontSize: 10.0))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MySliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final bool splitScreenMode;

  MySliverAppBar({
    @required this.expandedHeight,
    this.splitScreenMode = false,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final appBarHeight = expandedHeight - shrinkOffset;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Image.network(
        //   'https://dokumen.payuni.co.id/logo/xenaja/bghome.png',
        //   fit: BoxFit.cover,
        // ),
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.red,
            image: DecorationImage(
              image: NetworkImage(
                  'https://dokumen.payuni.co.id/logo/xenaja/bghome.png'), // Ganti dengan URL gambar Anda
              fit: BoxFit.cover,
            ),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Opacity(
              opacity: shrinkOffset / expandedHeight,
              child: Image.network(
                  'https://dokumen.payuni.co.id/logo/xenaja/newLayout/logoPutih.png'),
            ),
          ),
        ),
        SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.only(left: 20, top: 75),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Opacity(
                  opacity: (1 - shrinkOffset / expandedHeight),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Image.network(
                      'https://dokumen.payuni.co.id/logo/xenaja/newLayout/logoPutih.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(right: 20),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 70,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow: [
                              BoxShadow(
                                  color: Color(0x19111111),
                                  offset: Offset(0, 5),
                                  blurRadius: 2.0)
                            ]),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Total Balance",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w300,
                                          color: Color(0xff333333),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        formatRupiah(bloc
                                            .user.valueWrapper?.value.saldo),
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff333333)),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Transaksi Hari Ini",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w300,
                                          color: Color(0xff333333),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        formatNumber(bloc.todayTrxCount
                                            .valueWrapper?.value.totalTrx),
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff945a90)),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: MenuToolPopay(),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => 80;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
