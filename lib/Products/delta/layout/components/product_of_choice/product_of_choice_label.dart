// @dart=2.9

import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:mobile/Products/delta/layout/components/product_of_choice/product_of_choice_label.style.dart';
import 'package:mobile/screen/marketplace/belanja.dart';

class ProductOfChoiceLabel extends StatelessWidget {
  const ProductOfChoiceLabel({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Txt(
                'Belanja Untuk Kebutuhanmu',
                style: ProductOfChoiceLabelStyle.text,
              ),
              SizedBox(height: 5),
              Txt(
                'Dapatkan diskon voucher belanja',
                style: ProductOfChoiceLabelStyle.text.clone()
                  ..fontSize(13)
                  ..fontWeight(FontWeight.normal),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BelanjaPage(),
            ),
          ),
          child: Container(
            padding: EdgeInsets.only(right: 20.0, top: 5.0, bottom: 5.0),
            child: Txt(
              'Lihat Semua',
              style: ProductOfChoiceLabelStyle.text.clone()
                ..fontSize(14)
                ..fontWeight(FontWeight.w600)
                ..textColor(Color(0xffF74C72))
                ..letterSpacing(0),
            ),
          ),
        ),
      ],
    );
  }
}
