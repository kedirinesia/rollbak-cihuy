// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/mp_produk.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/marketplace/detail_produk.dart';
import 'package:mobile/screen/marketplace/list_produk.dart';
import 'package:shimmer/shimmer.dart';

class ProdukPilihan extends StatelessWidget {
  final List<ProdukMarket> products;
  const ProdukPilihan(this.products, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilihan Untukmu',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.7,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Produk Spesial Untukmu',
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
                    builder: (_) => ListProdukMarketplace(),
                  ),
                ),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 18.0, vertical: 15.0),
                  child: Text(
                    'Lihat Semua',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.only(top: 2, left: 2, right: 2),
            color: Colors.grey.shade100,
            height: 220, // Jika ada rating 240
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, i) => SizedBox(width: 2),
              itemBuilder: (ctx, i) {
                ProdukMarket product = products[i];

                return InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailMarketplace(
                        product.id,
                        product.title,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2.4,
                          color: Colors.white,
                          padding: EdgeInsets.only(
                              top: 10, right: 10, bottom: 8, left: 10),
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(7)),
                                          child: CachedNetworkImage(
                                            imageUrl: product.thumbnail,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 15.0),
                                    Container(
                                      child: Text(
                                        product.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 6.0),
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text(
                                        formatRupiah(product.price),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xffF74C72),
                                        ),
                                      ),
                                    ),
                                    // SizedBox(height: 10.0),
                                    // Container(
                                    //   child: Row(
                                    //     children: [
                                    //       RatingBar.builder(
                                    //         initialRating: 10.0,
                                    //         itemSize: 12.0,
                                    //         minRating: 1,
                                    //         direction: Axis.horizontal,
                                    //         allowHalfRating: true,
                                    //         itemCount: 5,
                                    //         itemPadding:
                                    //             EdgeInsets.only(right: 1.4),
                                    //         itemBuilder: (context, _) => Icon(
                                    //           Icons.star,
                                    //           color: Colors.amber,
                                    //         ),
                                    //         onRatingUpdate: (rating) {
                                    //           print(rating);
                                    //         },
                                    //       ),
                                    //       SizedBox(width: 5),
                                    //       Container(
                                    //         margin: EdgeInsets.only(top: 2.0),
                                    //         child: Text(
                                    //           '10.0',
                                    //           style: TextStyle(
                                    //             fontSize: 10.0,
                                    //           ),
                                    //         ),
                                    //       )
                                    //     ],
                                    //   ),
                                    // ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingProdukPilihan extends StatelessWidget {
  const LoadingProdukPilihan({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(top: 15.0, left: 18, bottom: 5, right: 18),
            child: Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilihan Untukmu',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.7,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Produk Spesial Untukmu',
                      style: TextStyle(
                        fontSize: 11.5,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10.0),
          Container(
            padding: EdgeInsets.only(top: 2, left: 2, right: 2),
            color: Colors.grey.shade100,
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (_, i) => SizedBox(width: 2),
              itemBuilder: (ctx, i) {
                return Column(
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.only(
                            top: 10, right: 10, bottom: 8, left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 130,
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(7)),
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        color: Colors.white,
                                      ),
                                      child: Container(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 15.0),
                            Container(
                              height: 12,
                              width: 90,
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: Colors.white,
                                  ),
                                  child: Container(),
                                ),
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 12,
                                          width: 50,
                                          child: Shimmer.fromColors(
                                            baseColor: Colors.grey.shade300,
                                            highlightColor:
                                                Colors.grey.shade100,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                                color: Colors.white,
                                              ),
                                              child: Container(),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 6.0),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
