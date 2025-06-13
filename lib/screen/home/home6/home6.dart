// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/component/carousel-depan.dart';
import 'package:mobile/component/menudepan.dart';
import 'package:mobile/component/rewards.dart';
import 'package:mobile/models/app_info.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/profile/reward/list_reward.dart';
import 'package:mobile/screen/topup/topup.dart';
import 'package:mobile/screen/wd/withdraw.dart';
import 'home6_model.dart';
import 'package:mobile/Products/pakaiaja/layout/card_info.dart';

class Home6App extends StatefulWidget {
  @override
  _Home6AppState createState() => _Home6AppState();
}

class _Home6AppState extends Home6Model {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: ScrollPhysics(),
      shrinkWrap: true,
      children: <Widget>[
        Container(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              InkWell(
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => TopupPage())),
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  margin: EdgeInsetsDirectional.only(end: 5.0),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(30.0),
                          bottomRight: Radius.circular(30.0))),
                  child: Text('Topup',
                      style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Icon(Icons.account_balance_wallet),
                  ),
                  title: Text(formatRupiah(bloc.user.valueWrapper?.value.saldo),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15.0)),
                  subtitle:
                      Text('Saldo PakeAja', style: TextStyle(fontSize: 12.0)),
                ),
              ),
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Icon(Icons.account_balance_wallet),
                  ),
                  title: Text(
                      formatRupiah(bloc.user.valueWrapper?.value.komisi),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15.0)),
                  subtitle:
                      Text('Komisi Tersedia', style: TextStyle(fontSize: 12.0)),
                ),
              ),
            ],
          ),
        ),
        Container(
          color: Colors.grey.shade200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                width: 50.0,
                height: 50.0,
                padding: EdgeInsets.all(10.0),
                child: InkWell(
                  onTap: () async {
                    return Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => WithdrawPage()));
                  },
                  child: CachedNetworkImage(
                      imageUrl:
                          'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2FPakeAja%2Fbussiness-and-finance.png?alt=media&token=6c649761-535b-46a5-ab69-cd42f482e3b4',
                      width: 32.0),
                ),
              ),
              Container(
                width: 1.0,
                height: 50.0,
                color: Colors.grey.shade400,
              ),
              Expanded(
                child: ListTile(
                  title: Text('PakeAja Point',
                      style: TextStyle(
                        fontSize: 12.0,
                      )),
                  subtitle: Text(
                      formatNumber(bloc.user.valueWrapper?.value.poin) + ' Pts',
                      style: TextStyle(
                          fontSize: 15.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold)),
                  trailing: TextButton(
                    child: Text('Redeem Sekarang'),
                    onPressed: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => ListReward())),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.0),
        CarouselDepan(),
        MenuDepan(grid: 5, baris: 2, gradient: true),
        // Container(
        //     height: 40.0,
        //     width: double.infinity,
        //     // margin: EdgeInsets.all(10.0),
        //     decoration: BoxDecoration(
        //         color: Theme.of(context).primaryColor,
        //         borderRadius: BorderRadius.circular(0.0),
        //         border: Border.all(
        //             color: Theme.of(context).primaryColor, width: 5)),
        //     child: Marquee(
        //       text:
        //           'SEPUTAR INFO : Selalu waspada terhadap segala bentuk PENIPUAN,pihak kami tidak pernah telp / meminta kode OTP apapun. Biasakan SAVE kontak kami 08980000073 atau bisa ke LIVECHAT',
        //       style: TextStyle(color: Colors.white),
        //       blankSpace: 100.0,
        //     )),
        SizedBox(height: 20.0),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text('PakeAja Info',
              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Text('Lihat Info Menarik dari PakeAja Disini',
              style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal)),
        ),
        SizedBox(height: 10.0),
        CardInfo(),
        SizedBox(height: 5.0),
        Container(
            width: double.infinity,
            color: Colors.grey.withOpacity(.15),
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text('Hadiah',
                        style: TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Text('Raih hadiah menarik dari PakeAja',
                        style: TextStyle(
                            fontSize: 12.0, fontWeight: FontWeight.normal)),
                  ),
                  SizedBox(height: 15),
                  RewardComponent(),
                ])),
        SizedBox(height: 15)
      ],
    );
  }
}
