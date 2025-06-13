// @dart=2.9

import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:mobile/Products/ualreload/layout/components/information/information_label.dart';
import 'package:mobile/Products/ualreload/layout/components/information/information_nothing.style.dart';

class InformationNothing extends StatelessWidget {
  const InformationNothing({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InformationLabel(),
          Parent(
            style: InformationNothingStyle.wrapper,
            child: Container(
              child: Center(
                child: Txt(
                  'Info Dan Promo Spesial Belum Tersedia',
                  style: InformationNothingStyle.text,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
