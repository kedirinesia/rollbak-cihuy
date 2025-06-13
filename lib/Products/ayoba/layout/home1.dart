// @dart=2.9

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/Products/ayoba/config.dart';
import 'package:mobile/Products/ayoba/layout/components/dashboard_panel.dart';
import 'package:mobile/Products/ayoba/layout/components/rewards.dart';
import 'package:mobile/Products/ayoba/layout/components/sticky_navbar.dart';
import 'package:mobile/Products/ayoba/layout/components/carousel_header.dart';
import 'package:mobile/Products/ayoba/layout/components/menu_depan.dart';
import 'package:mobile/Products/ayoba/layout/components/carousel_depan.dart';
import 'package:mobile/Products/ayoba/layout/qris.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/mp_kategori.dart';
import 'package:mobile/models/mp_produk.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/kyc/reject.dart';
import 'package:mobile/screen/kyc/verification1.dart';
import 'package:mobile/screen/kyc/waiting.dart';
import 'package:mobile/screen/marketplace/list_produk.dart';

class HomeAyoba1 extends StatefulWidget {
  @override
  _HomeAyoba1State createState() => _HomeAyoba1State();
}

class _HomeAyoba1State extends State<HomeAyoba1> {
  List<ProdukMarket> _products = [];
  bool loading = true;
  bool isTransparent = true;

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  @override
  void dispose() {
    super.dispose();
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

  Future<void> getProducts() async {
    try {
      http.Response response = await http.get(
          Uri.parse('$apiUrl/market/products'),
          headers: {'Authorization': bloc.token.valueWrapper?.value});

      if (response.statusCode == 200) {
        List<dynamic> datas = json.decode(response.body)['data'];
        _products = datas.map((data) => ProdukMarket.fromJson(data)).toList();

        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        loading = false;
      });
    }
  }

  Future<List<CategoryModel>> categories() async {
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
          await getProducts();
          setState(() {});
        },
        child: Column(
          children: [
            StickyNavBar(isTransparent: false),
            Container(
              color: Colors.white,
              child: Container(
                padding: EdgeInsets.all(15),
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
                                right: 15.0,
                                left: 15.0,
                                bottom: 15.0,
                                top: 5.0),
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0x3f000000).withOpacity(0.2),
                                    offset: Offset(0, 0),
                                    blurRadius: 5)
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: 10.0, left: 20.0, right: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Upgrade ke Akun Premium! Nikmatin Layanan QRIS Toko",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xff000000),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(Icons.check_box,
                                          color: Color(0xff79B4CD), size: 12),
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
                                          color: Color(0xff79B4CD), size: 12),
                                      SizedBox(width: 3),
                                      Text(
                                        "Biaya Admin 0,8%",
                                        style: TextStyle(fontSize: 11),
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
                                              MaterialStateProperty.all(
                                                  Theme.of(context)
                                                      .primaryColor),
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                          minimumSize:
                                              MaterialStateProperty.all<Size>(
                                                  Size(0, 25))),
                                      child: Text(
                                        "Upgrade",
                                        style: TextStyle(
                                            fontSize: 12,
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
                    CarouselDepan(),
                    SizedBox(height: 10),
                    Container(
                      color: Colors.white,
                      child: kategoriWidget(),
                    ),
                    SizedBox(height: 10),
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

  Widget kategoriWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kategori Produk',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Kategori produk yang mungkin anda cari',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        FutureBuilder<List<CategoryModel>>(
          future: categories(),
          builder: (ctx, snapshot) {
            if (!snapshot.hasData)
              return Container(
                width: double.infinity,
                height: ((MediaQuery.of(context).size.width - 60) * .25) * 1.5,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                    valueColor:
                        AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                  ),
                ),
              );

            if (snapshot.data.length == 0)
              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                child: Center(
                  child: Text(
                    'Belum Ada Kategori',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );

            return Container(
              height: ((MediaQuery.of(context).size.width - 60) * .25) * 1.5,
              child: ListView.separated(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data.length,
                separatorBuilder: (_, i) => SizedBox(width: 10),
                itemBuilder: (ctx, i) {
                  CategoryModel kategori = snapshot.data[i];

                  return AspectRatio(
                    aspectRatio: 1 / 1.5,
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ListProdukMarketplace(
                            categoryId: kategori.id,
                            categoryName: kategori.judul,
                          ),
                        ),
                      ),
                      child: Container(
                        width: (MediaQuery.of(context).size.width - 60) * .25,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: CachedNetworkImage(
                                      imageUrl: kategori.thumbnailUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: Text(
                                kategori.judul,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black87,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
