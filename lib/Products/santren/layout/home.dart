// @dart=2.9

import 'dart:convert';
import 'dart:async';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/Products/santren/layout/qris/qris_page.dart';
import 'package:mobile/Products/santren/layout/home_model.dart';
import 'package:mobile/Products/santren/layout/transfer.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/Products/santren/layout/card_info.dart';
import 'package:mobile/component/carousel-depan.dart';
import 'package:mobile/Products/santren/layout/menudepan.dart';
import 'package:mobile/component/rewards.dart';
import 'package:mobile/models/mp_kategori.dart';
import 'package:mobile/models/mp_produk.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/profile/invite/invite.dart';
import 'package:mobile/screen/transfer_saldo/transfer_by_qr.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/utils/debug_helper.dart';
import 'package:badges/badges.dart' as BadgeModule;
import 'package:hive/hive.dart';

class Home4App extends StatefulWidget {
  @override
  _Home4AppState createState() => _Home4AppState();
}

class _Home4AppState extends Home4Model {
  AnimationController _animationController;
  int _points = 0;
  bool _isBalanceVisible = false;
  StreamController<int> _streamController = StreamController<int>.broadcast();

  @override
  void initState() {
    _animationController =
        AnimationController(duration: Duration(seconds: 3), vsync: this);
    super.initState();
    refreshSaldo(); // Load data poin saat pertama kali
    getUnreadNotification(); // Load unread notification count
  }

  @override
  void dispose() {
    _animationController.dispose();
    _streamController.close();
    super.dispose();
  }

  Future<void> getUnreadNotification() async {
    try {
      http.Response response = await http.get(
          Uri.parse('$apiUrl/outbox/unread/count'),
          headers: {'Authorization': bloc.token.valueWrapper?.value});

      var boxUnreadNotification = Hive.box('unread-notification');

      if (response.statusCode == 200) {
        int unreadNotification = json.decode(response.body)['data'];

        if (boxUnreadNotification.isEmpty) {
          Hive.box('unread-notification').add(unreadNotification);
        } else {
          Hive.box('unread-notification').putAt(0, unreadNotification);
        }

        if (!_streamController.isClosed) {
          _streamController.sink.add(unreadNotification);
        }
      } else {
        if (boxUnreadNotification.isNotEmpty) {
          Hive.box('unread-notification').putAt(0, 0);
        }
      }
    } catch (e) {
      DebugHelper.debugPrint('Error: $e');
    }
  }

  Future<void> refreshSaldo() async {
    try {
      http.Response response = await http.get(
        Uri.parse('$apiUrl/user/info'),
        headers: {
          'Authorization': bloc.token.valueWrapper?.value,
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body)['data'];
        UserModel user = UserModel.fromJson(data);
        bloc.user.add(user);
        
     
        if (data['points'] != null) {
          _points = data['points'];
        } else if (data['poin'] != null) {
          _points = data['poin'];
        } else if (data['reward_points'] != null) {
          _points = data['reward_points'];
        }
        
        setState(() {});
      }
    } catch (e) {
      DebugHelper.debugPrint('"Error saat memngambil saldo: $e"');
    }
    
    // Also refresh notification count
    getUnreadNotification();
  }

  Future<List<ProdukMarket>> getProducts() async {
    try {
      http.Response response = await http.get(
          Uri.parse('$apiUrl/market/products'),
          headers: {'Authorization': bloc.token.valueWrapper?.value});

      if (response.statusCode == 200) {
        List<dynamic> datas = json.decode(response.body)['data'];
        return datas.map((e) => ProdukMarket.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      DebugHelper.debugPrint('Error: $e');
      return [];
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    List<CategoryModel> categories = [];

    http.Response response = await http.get(
        Uri.parse('$apiUrl/market/category'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      datas.forEach((data) {
        if (data['judul'] != null &&
            data['description'] != null &&
            data['thumbnail'] != null) {
          categories.add(CategoryModel.fromJson(data));
        }
      });
    }

    return categories;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFe4ebfd),
      child: Column(
        children: [
          SafeArea(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 20),
              decoration: BoxDecoration(
                color: Color(0xFFe4ebfd),
              ),
              child: Column(
                children: [
            
                  Row(
                    
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/logoHomeSantren.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        //  / SizedBox(width: 10),
                          // Text(
                          //   'Santren PAY',
                          //   style: TextStyle(
                          //     color: Colors.white,
                          //     fontSize: 18,
                          //     fontWeight: FontWeight.bold,
                          //   ),
                          // ),
                        ],
                      ),
                      StreamBuilder(
                        stream: _streamController.stream,
                        builder: (context, snapshot) {
                          var unreadNotification = Hive.box('unread-notification').values;

                          return unreadNotification.isEmpty || unreadNotification.first == 0
                              ? InkWell(
                                  onTap: () => Navigator.of(context).pushNamed('/notifikasi'),
                                  child: Icon(
                                    Icons.notifications_outlined,
                                    color: Color(0xFF0652DD),
                                    size: 24,
                                  ),
                                )
                              : InkWell(
                                  onTap: () => Navigator.of(context).pushNamed('/notifikasi'),
                                  child: BadgeModule.Badge(
                                    badgeContent: Text(
                                      '${unreadNotification.first}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                      ),
                                    ),
                                    badgeColor: Colors.red,
                                    toAnimate: false,
                                    child: Icon(
                                      Icons.notifications_outlined,
                                      color: Color(0xFF0652DD),
                                      size: 24,
                                    ),
                                  ),
                                );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          Container(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 40),
            decoration: BoxDecoration(
              color: Color(0xFF0652DD),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
              
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Row(
                        children: [
                          Text(
                            'Saldo SPcash',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isBalanceVisible = !_isBalanceVisible;
                              });
                            },
                            child: Icon(
                              _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white,
                            size: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        _isBalanceVisible 
                          ? formatRupiah(100000000)
                          : 'Rp ********',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                          // fontStyle: FontStyle.italic,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    ),
                  ),
                ),
                
            // /    SizedBox(width: 50),
             
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      topRight: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/img/santren/iconPoint.png',
                        width: 25,
                        height: 25,
                      //  color: Colors.white,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '100 Poin',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 7),
          // Action Buttons Section
          Container(
            margin: EdgeInsets.symmetric(horizontal: 12),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xFF0652DD),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => QrisPage()));
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Color(0xFF0652DD),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(0.5),
                            child: Image.asset(
                              'assets/img/santren/iconatas1.PNG',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                   
                        Text(
                          'QRIS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.of(context).pushNamed('/topup'),
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Color(0xFF0652DD),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(6),
                            child: Image.asset(
                              'assets/img/santren/iconatas2.PNG',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        
                        Text(
                          'Top Up',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => TransferManuPage()));
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Color(0xFF0652DD),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(6),
                            child: Image.asset(
                              'assets/img/santren/iconatas3.PNG',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                   //     SizedBox(height: 6),
                        Text(
                          'Transfer',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.of(context).pushNamed('/withdraw'),
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Color(0xFF0652DD),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(6),
                            child: Image.asset(
                              'assets/img/santren/iconatas4.PNG',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                     //   SizedBox(height: 6),
                        Text(
                          'Tarik',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          //   GradientLine(),
        //  SizedBox(height: 10),
          // Scrollable content inside white card
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: RefreshIndicator(
                onRefresh: refreshSaldo,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                     // SizedBox(height: 16),
                      Transform.translate(
                        offset: Offset(0, -6),
                        child: MenuDepan(grid: 5, baris: 3, gradient: true),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: InviteFriendBox(context: context),
                      ),
                      SizedBox(height: 16),
                      // 3 Separate Buttons Below Card
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).canvasColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      Navigator.of(context).pushNamed('/invite');
                                    },
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.favorite,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Baznas',
                                          style: TextStyle(
                                            color: Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).canvasColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      Navigator.of(context).pushNamed('/referral');
                                    },
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.account_balance_wallet,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Dompet Dhuafa',
                                          style: TextStyle(
                                            color: Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).canvasColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      Navigator.of(context).pushNamed('/commission');
                                    },
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.menu_book,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Al-Quran Digital',
                                          style: TextStyle(
                                            color: Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.only(left: 12, right: 12, top: 6),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Info Terbaru',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      CardInfo(),
                      SizedBox(height: 22),
                      Padding(
                        padding: EdgeInsets.only(left: 12, right: 12, top: 6),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Hadiah Menarik',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      RewardComponent(),
                      SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget InviteFriendBox({BuildContext context}) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.02),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Color(0xFF0652DD),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text(
                    "Undang Teman anda sebanyak banyaknya Dapat Bonus referal 10.000 dan komisi transaksi downline anda",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Text(
                  //   "referal 10.000 dan komisi transaksi downline anda",
                  //   style: TextStyle(
                  //     color: Colors.white,
                  //     fontSize: 14,
                  //   ),
                  // budiono ssiregar)
                ],
              ),
            ),
            SizedBox(width: 16),
            // Icon
            Icon(
              Icons.person_add_alt_1_outlined,
              color: Colors.white,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}

class GradientLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,  
      //width: double.infinity,  
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFe4ebfd), 
            Color(0xFFe4ebfd),  
          ],
          begin: Alignment.topCenter,  
          end: Alignment.bottomCenter,  
        ),
      ),
    );
  }
}

class PanelSemuaMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
      child: GridView(
        shrinkWrap: true,
        primary: false,
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          Container(
            // color: Colors.red.withOpacity(.1),
            child: InkWell(
              onTap: () async {
                String barcode = (await BarcodeScanner.scan()).toString();
                DebugHelper.debugPrint('barcode.toString()');
                if (barcode.isNotEmpty) {
                  return Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => TransferByQR(barcode)));
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: LinearGradient(
                          begin: AlignmentDirectional.topCenter,
                          end: AlignmentDirectional.bottomEnd,
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(.1),
                            Theme.of(context).primaryColor.withOpacity(.1),
                            Theme.of(context).primaryColor.withOpacity(.1)
                          ]),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: CachedNetworkImage(
                        imageUrl:
                            'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/assets%2Ficons%2Fqr-code-scan.png?alt=media&token=e6b8db9f-d654-4d81-8437-29e91009e636',
                        width: 40.0,
                        fit: BoxFit.cover),
                  ),
                  SizedBox(height: 10.0),
                  Flexible(
                    child: Text(
                      'Scan',
                      style: TextStyle(
                          fontSize: 10.0,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.bold),
                      softWrap: true,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            // color: Colors.red.withOpacity(.1),
            child: InkWell(
              onTap: () => Navigator.of(context).pushNamed('/myqr'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: LinearGradient(
                          begin: AlignmentDirectional.topCenter,
                          end: AlignmentDirectional.bottomEnd,
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(.1),
                            Theme.of(context).primaryColor.withOpacity(.1),
                            Theme.of(context).primaryColor.withOpacity(.1)
                          ]),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: CachedNetworkImage(
                        imageUrl:
                            'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/assets%2Ficons%2Fqr-code.png?alt=media&token=a2d4ead5-b4ed-498d-861b-1f9f92ba1a94',
                        width: 40.0,
                        fit: BoxFit.cover),
                  ),
                  SizedBox(height: 10.0),
                  Flexible(
                    child: Text(
                      'My QR',
                      style: TextStyle(
                          fontSize: 10.0,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.bold),
                      softWrap: true,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            // color: Colors.red.withOpacity(.1),
            child: InkWell(
              onTap: () => Navigator.of(context).pushNamed('/transfer'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: LinearGradient(
                          begin: AlignmentDirectional.topCenter,
                          end: AlignmentDirectional.bottomEnd,
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(.1),
                            Theme.of(context).primaryColor.withOpacity(.1),
                            Theme.of(context).primaryColor.withOpacity(.1)
                          ]),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: CachedNetworkImage(
                        imageUrl:
                            'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/assets%2Ficons%2Ftransfer%20(1).png?alt=media&token=ebd17176-58cf-4b5a-870e-88f718f1b192',
                        width: 40.0,
                        fit: BoxFit.cover),
                  ),
                  SizedBox(height: 10.0),
                  Flexible(
                    child: Text(
                      'Transfer',
                      style: TextStyle(
                          fontSize: 10.0,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.bold),
                      softWrap: true,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            // color: Colors.red.withOpacity(.1),
            child: InkWell(
              onTap: () => Navigator.of(context).pushNamed('/withdraw'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: LinearGradient(
                          begin: AlignmentDirectional.topCenter,
                          end: AlignmentDirectional.bottomEnd,
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(.1),
                            Theme.of(context).primaryColor.withOpacity(.1),
                            Theme.of(context).primaryColor.withOpacity(.1)
                          ]),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: CachedNetworkImage(
                        imageUrl:
                            'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/assets%2Ficons%2Fmoney.png?alt=media&token=fea2189f-04f8-43d9-bc0f-1f1d386c7de4',
                        width: 40.0,
                        fit: BoxFit.cover),
                  ),
                  SizedBox(height: 10.0),
                  Flexible(
                    child: Text(
                      'Withdraw',
                      style: TextStyle(
                          fontSize: 10.0,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.bold),
                      softWrap: true,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 5,
            childAspectRatio: 0.8,
            mainAxisSpacing: 10.0),
      ),
    );
  }
}

