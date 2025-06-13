// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mobile/Products/alpay/layout/components/product_of_choice/product_of_choice_label.dart';
import 'package:mobile/models/mp_produk.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/marketplace/detail_produk.dart';

class ProductOfChoice extends StatelessWidget {
  final List<ProdukMarket> products;
  const ProductOfChoice(this.products, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductOfChoiceLabel(),
          Container(
            padding: EdgeInsets.only(top: 2, bottom: 10, left: 7.0, right: 7),
            color: Colors.white,
            child: GridView.builder(
              padding: EdgeInsets.all(5),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: .62,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                ProdukMarket product = products[index];
                return InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailMarketplace(
                        product.id,
                        product.title,
                      ),
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.only(
                        top: 10, right: 10, bottom: 15, left: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          offset: const Offset(0.0, 1.1),
                          blurRadius: 1.0,
                          spreadRadius: 0.2,
                        ),
                        BoxShadow(
                          color: Colors.grey.shade300,
                          offset: const Offset(-0.1, -0.1),
                          blurRadius: 1.0,
                          spreadRadius: 0.2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(7)),
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
                              SizedBox(height: 10.0),
                              Container(
                                child: Row(
                                  children: [
                                    RatingBar.builder(
                                      initialRating: 10.0,
                                      itemSize: 12.0,
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemPadding: EdgeInsets.only(right: 1.4),
                                      itemBuilder: (context, _) => Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      onRatingUpdate: (rating) {
                                        print(rating);
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Container(
                                      margin: EdgeInsets.only(top: 2.0),
                                      child: Text(
                                        '10.0',
                                        style: TextStyle(
                                          fontSize: 10.0,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
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
