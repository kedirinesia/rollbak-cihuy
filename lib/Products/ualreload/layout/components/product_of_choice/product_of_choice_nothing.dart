// @dart=2.9

import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:mobile/Products/ualreload/layout/components/product_of_choice/product_of_choice_label.dart';
import 'package:mobile/Products/ualreload/layout/components/product_of_choice/product_of_choice_nothing.style.dart';

class ProductOfChoiceNothing extends StatelessWidget {
  const ProductOfChoiceNothing({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductOfChoiceLabel(),
          Parent(
            style: ProductOfChoiceNothingStyle.wrapper,
            child: Container(
              child: Center(
                child: Txt(
                  'Produk Belanja Belum Tersedia',
                  style: ProductOfChoiceNothingStyle.text,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
