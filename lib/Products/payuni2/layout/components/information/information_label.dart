// @dart=2.9

import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:mobile/Products/payuni2/layout/components/information/information_label.style.dart';
import 'package:mobile/Products/payuni2/layout/components/information/other_information.dart';
import 'package:mobile/models/info.dart';

class InformationLabel extends StatelessWidget {
  final List<InfoModel> informations;
  const InformationLabel({this.informations, Key key}) : super(key: key);

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
                'Info Dan Promo Spesial',
                style: InformationLabelStyle.text,
              ),
              SizedBox(height: 5),
              Txt(
                'Dapatkan Infomasi menarik dari payuni',
                style: InformationLabelStyle.text.clone()
                  ..fontSize(13)
                  ..fontWeight(FontWeight.normal),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OtherInformation(informations),
            ),
          ),
          child: Container(
            padding: EdgeInsets.only(right: 20.0, top: 5.0, bottom: 5.0),
            child: Txt(
              'Lihat Semua',
              style: InformationLabelStyle.text.clone()
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
