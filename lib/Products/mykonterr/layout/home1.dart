// @dart=2.9

import 'dart:convert';

import 'package:badges/badges.dart' as BadgeModule;
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile/component/rewards.dart';
import 'package:mobile/Products/mykonterr/layout/components/card_info.dart';
import 'package:mobile/Products/mykonterr/layout/components/banner.dart';
import 'package:mobile/Products/mykonterr/layout/cs.dart';
import 'package:mobile/Products/mykonterr/layout/kirim-saldo.dart';
import 'package:mobile/Products/mykonterr/layout/components/menu_depan.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/mp_kategori.dart';
import 'package:mobile/models/mp_produk.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/notifikasi/notifikasi.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/screen/profile/invite/invite.dart';
import 'package:mobile/screen/transfer_saldo/transfer_by_qr.dart';
import 'package:mobile/screen/wd/withdraw.dart';

class PayuniHome extends StatefulWidget {
  @override
  _PayuniHomeState createState() => _PayuniHomeState();
}

class _PayuniHomeState extends State<PayuniHome>
    with SingleTickerProviderStateMixin {
  int carouselIndex = 0;
  bool isTransparent = true;
  Animation<Color> _bgColor;
  Animation<Color> _inputColor;
  Animation<Color> _iconColor;

  bool isSearch = false;
  TextEditingController searchQuery = TextEditingController();
  ScrollController _scrollController = ScrollController();
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset >= 100 && isTransparent) {
        _animationController.forward();
        setState(() {
          isTransparent = false;
        });
      } else if (_scrollController.offset < 100 && !isTransparent) {
        _animationController.reverse();
        setState(() {
          isTransparent = true;
        });
      }
    });
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 0),
    );
    _bgColor = ColorTween(
      begin: Colors.transparent,
      end: Colors.white,
    ).animate(_animationController);
    _iconColor = ColorTween(
      begin: Colors.white,
      end: Colors.grey,
    ).animate(_animationController);
    _inputColor = ColorTween(
      begin: Colors.white,
      end: Colors.grey.withOpacity(.15),
    ).animate(_animationController);
  }

  @override
  void dispose() {
    searchQuery.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              updateUserInfo();
              setState(() {});
              showToast(context, 'Berhasil memperbarui data');
            },
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: Container(
                    child: BannerComponent(),
                  ),
                ),
                // SizedBox(height: 15),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        MenuComponent(),
                        // SizedBox(height: 5),
                        Container(
                          margin: EdgeInsets.only(right: 20),
                          child: ListTile(
                            title: Text('Info Menarik dari MyKonter',
                                style: TextStyle(
                                    fontSize: 13.0, fontWeight: FontWeight.bold, color: Theme.of(context).secondaryHeaderColor)),
                            subtitle: Text(
                                'Baca Info Supaya Tidak Ketinggalan Kebahagiaan',
                                style: TextStyle(
                                    fontSize: 11.0, color: Colors.grey[500])),
                          ),
                        ),
                        CardInfo(),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(left: 10.0, right: 10.0),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 20.0),
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
                              borderRadius: BorderRadius.circular(15.0)),
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
                                  'Mengajak Teman Kamu Untuk Menggunakan MyKonter adalah Salah Satu Cara Untuk Mendapatkan Penghasilan Tambahan Buat Kamu',
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
                                            color: Colors.white, width: 1.0),
                                        borderRadius: BorderRadius.circular(15.0)),
                                    child: Text('Undang Teman',
                                        style: TextStyle(
                                            fontSize: 12.0, color: Colors.white)),
                                  ))
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          margin: EdgeInsets.only(right: 20),
                          child: ListTile(
                            title: Text(
                              'Dapat Hadiah dari My Konter',
                              style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            subtitle: Text(
                              'Kumpulkan Poin Kamu dan Tukarkan dengan Reward yang Tersedia Dari My Konter',
                              style: TextStyle(
                                fontSize: 11.0,
                                color: Colors.grey[500]
                              ),
                            ),
                          ),
                        ),
                        RewardComponent()
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Image.network(
                      'https://dokumen.payuni.co.id/logo/mykonter/logowebcopy.png',
                      height: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Hai kak ${bloc.username.valueWrapper?.value.split(' ')[0]}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CS1(),
                    ),
                  ),
                  // borderRadius: BorderRadius.circular(32),
                  child: Container(
                    // height: 32,
                    // width: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(1),
                    child: Image.network(
                      'https://dokumen.payuni.co.id/logo/mykonter/custom/cs.png',
                      fit: BoxFit.contain,
                      height: 28,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => Notifikasi(),
                    ),
                  ),
                  child: Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
