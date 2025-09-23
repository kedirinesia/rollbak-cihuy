// @dart=2.9

import 'dart:convert';

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

class Home4App extends StatefulWidget {
  @override
  _Home4AppState createState() => _Home4AppState();
}

class _Home4AppState extends Home4Model {
  AnimationController _animationController;
  int _points = 0;

  @override
  void initState() {
    _animationController =
        AnimationController(duration: Duration(seconds: 3), vsync: this);
    super.initState();
    refreshSaldo(); // Load data poin saat pertama kali
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
        
        // Ambil data poin dari response API
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
    return RefreshIndicator(
      onRefresh: refreshSaldo,
      child: ListView(
        children: [
        
          SafeArea(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 20),
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
                            height: 80,
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
                      Stack(
                        children: [
                          Icon(
                            Icons.notifications_outlined,
                           color: Color(0xFF0652DD),
                            size: 24,
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          Container(
            margin: EdgeInsets.symmetric(horizontal: 18, vertical: 5),
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
                          Icon(
                            Icons.visibility_off,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        // formatRupiah(bloc.user.valueWrapper?.value?.saldo ?? 0),
                         formatRupiah(9000000),
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
                      Icon(
                        Icons.monetization_on,
                        color: Colors.amber[700],
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '$_points Poin',
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
            margin: EdgeInsets.symmetric(horizontal: 20),
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
          SizedBox(height: 15),
          GradientLine(),
          SizedBox(height: 15),
          MenuDepan(grid: 5, baris: 3, gradient: true),
          InviteFriendBox(context: context),
          SizedBox(height: 30),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Info Terbaru',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          SizedBox(height: 20),
          CardInfo(),
          SizedBox(height: 30),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Hadiah Menarik',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          SizedBox(height: 10.0),
          RewardComponent(),
          SizedBox(height: 40.0),
        ],
      ),
    );
  }


  Widget InviteFriendBox({BuildContext context}) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.04),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [Color(0xFF0652DD), Color(0xFF0652DD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: w * 0.05, vertical: h * 0.032), // PAD KECIL
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + Judul
            Row(
              children: [
                Icon(Icons.group_add,
                    color: Colors.white, size: w * 0.058), // lebih kecil
                SizedBox(width: w * 0.018),
                Expanded(
                  child: Text(
                    "Dapatkan Komisi dari Ajak Teman Kamu",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: w * 0.041, // lebih kecil
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: h * 0.02), // jarak kecil
            // Deskripsi
            Text(
              "Mengajak Teman Kamu Untuk Menggunakan Payuni adalah Salah Satu Cara Untuk Mendapatkan Penghasilan Tambahan Buat Kamu.",
              style: TextStyle(
                color: Colors.white70,
                fontSize: w * 0.029, // lebih kecil
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: h * 0.020), // jarak kecil
            // Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: Icon(Icons.share, color: Colors.white, size: w * 0.045),
                label: Padding(
                  padding: EdgeInsets.symmetric(vertical: h * 0.009),
                  child: Text(
                    "Undang Teman",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: w * 0.037,
                    ),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.transparent,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: Size(0, 0),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => InvitePage()),
                  );
                },
              ),
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
      height: 4, // Ketebalan garis
      width: double.infinity, // Lebar garis sesuai layar
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey, // Warna awal gradasi (atas)
            Colors.white, // Warna akhir gradasi (bawah)
          ],
          begin: Alignment.topCenter, // Mulai dari atas
          end: Alignment.bottomCenter, // Berakhir di bawah
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
