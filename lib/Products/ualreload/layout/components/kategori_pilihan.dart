// @dart=2.9

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/Products/ualreload/config.dart';
import 'package:mobile/Products/ualreload/layout/more_categories.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/models/mp_kategori.dart';
import 'package:mobile/screen/marketplace/list_produk.dart';
import 'package:shimmer/shimmer.dart';

class KategoriPilihan extends StatefulWidget {
  KategoriPilihan({Key key}) : super(key: key);

  @override
  State<KategoriPilihan> createState() => _KategoriPilihanState();
}

class _KategoriPilihanState extends State<KategoriPilihan> {
  List<CategoryModel> _categories = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    getCategory();
  }

  Future<void> getCategory() async {
    try {
      http.Response response = await http.get(
        Uri.parse('$apiUrl/market/category'),
        headers: {'Authorization': bloc.token.valueWrapper?.value},
      );

      if (response.statusCode == 200) {
        List<dynamic> datas = json.decode(response.body)['data'];
        _categories =
            datas.map((data) => CategoryModel.fromJson(data)).toList();

        setState(() {
          loading = false;
        });
      } else {
        String message = json.decode(response.body)['message'] ??
            'Terjadi kesalahan pada server';
        final snackBar = Alert(message, isError: true);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? kategoryPilihanLoading()
        : Container(
            color: Colors.white,
            height: 292,
            child: Column(
              children: [
                Container(
                  child: Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                          top: 15.0,
                          left: 18,
                          bottom: 15.0,
                          right: 18,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pilihan Kategori',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.7,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Tersedia Beragam Kategori',
                              style: TextStyle(
                                fontSize: 11.5,
                                letterSpacing: 0.7,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MoreCategoriesPage(_categories),
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.only(
                            top: 15.0,
                            left: 18,
                            bottom: 15.0,
                            right: 18,
                          ),
                          child: Text(
                            'Lihat Semua',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xffF74C72),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            child: CachedNetworkImage(
                              imageUrl:
                                  'https://banner.payuni.co.id/payuni/kategori/ktg1.jpg',
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              height: double.infinity,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            color: Colors.grey.shade300,
                            child: GridView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                // childAspectRatio: 35 / 36,
                                crossAxisCount: 2,
                                mainAxisSpacing: 1,
                                crossAxisSpacing: 1,
                              ),
                              itemCount: 4,
                              itemBuilder: (BuildContext context, int index) {
                                CategoryModel category = _categories[index];
                                return InkWell(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ListProdukMarketplace(
                                        searchQuery: category.judul,
                                      ),
                                    ),
                                  ),
                                  child: Container(
                                    color: Colors.white,
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: Container(
                                              width: double.infinity,
                                              color: Colors.grey.shade200,
                                              child: CachedNetworkImage(
                                                imageUrl: category.thumbnailUrl,
                                                fit: BoxFit.cover,
                                              )),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(6),
                                          // color: Color(0xff438eba),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              gradient: LinearGradient(
                                                begin: Alignment.topRight,
                                                end: Alignment.bottomLeft,
                                                stops: [
                                                  0.2,
                                                  0.4,
                                                ],
                                                colors: [
                                                  Color(0xff0dade8),
                                                  Theme.of(context)
                                                      .primaryColor
                                                      .withOpacity(0.9),
                                                ],
                                              )),
                                          child: Center(
                                            child: Text(
                                              category.judul,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Widget kategoryPilihanLoading() {
    return Container(
      color: Colors.white,
      height: 292,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(
              top: 15.0,
              left: 18,
              bottom: 15.0,
              right: 18,
            ),
            child: Text(
              'Pilihan Kategori',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.7,
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.grey.shade300,
                      )),
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: Colors.grey.shade300,
                      child: GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          // childAspectRatio: 35 / 36,
                          crossAxisCount: 2,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                        ),
                        itemCount: 4,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            color: Colors.white,
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey.shade200,
                              highlightColor: Colors.grey.shade100,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                ),
                                child: Container(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
