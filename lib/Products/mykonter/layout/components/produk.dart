// @dart=2.9

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/mp_produk.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/modules.dart';
import 'package:mobile/screen/marketplace/belanja.dart';
import 'package:mobile/screen/marketplace/detail_produk.dart';

class ProdukMarketplace extends StatelessWidget {
  Future<List<ProdukMarket>> getProducts() async {
    http.Response response = await http.get(
      Uri.parse('$apiUrl/market/products'),
      headers: {
        'Authorization': bloc.token.valueWrapper?.value,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      return datas.map((e) => ProdukMarket.fromJson(e)).toList();
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Produk Rekomendasi untuk Anda',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Yuk ke My Konter!',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 15),
          Flexible(
            child: FutureBuilder<List<ProdukMarket>>(
              future: getProducts(),
              builder: (_, snapshot) {
                if (snapshot.hasError) {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        'Terjadi kesalahan saat memuat produk',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: SpinKitThreeBounce(
                        color: Theme.of(context).primaryColor,
                        size: 35,
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: .7,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                  ),
                  itemBuilder: (_, i) {
                    ProdukMarket produk = snapshot.data.elementAt(i);

                    return InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => ProductDetailMarketplace(
                                  produk.id, produk.title)));
                        },
                        child: Container(
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: CachedNetworkImage(
                                    imageUrl: produk.thumbnail,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                produk.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Spacer(),
                              Text(
                                formatRupiah(produk.price),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ));
                  },
                );
              },
            ),
          ),
          SizedBox(height: 10),
          MaterialButton(
            minWidth: double.infinity,
            color: Colors.white,
            child: Text('Produk Lainnya'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
              side: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 1,
              ),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BelanjaPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
