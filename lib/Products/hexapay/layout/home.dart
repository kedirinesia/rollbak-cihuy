// @dart=2.9

import 'dart:convert';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:marquee/marquee.dart';
import 'package:mobile/Products/hexapay/layout/transfer.dart';
import 'package:mobile/Products/hexapay/layout/qris/qris_page.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/Products/hexapay/layout/card_info.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/component/carousel-depan.dart';
import 'package:mobile/Products/hexapay/layout/menudepan.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/profile/reward/list_reward.dart';
import 'package:mobile/screen/topup/topup.dart';
import 'package:mobile/screen/transfer_saldo/transfer_by_qr.dart';
import 'package:mobile/screen/wd/withdraw.dart';

class PakeAjaHome extends StatefulWidget {
  @override
  _PakeAjaHomeState createState() => _PakeAjaHomeState();
}

class _PakeAjaHomeState extends State<PakeAjaHome> {
  Widget topPanel() {
    return Container(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          InkWell(
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => TopupPage())),
            child: Container(
              padding: EdgeInsets.all(12.5),
              margin: EdgeInsetsDirectional.only(end: 5.0),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0))),
              child: Text('Topup',
                  style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),
          Expanded(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity(vertical: -2.5),
              leading: Container(
                width: 35,
                height: 35,
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.only(left: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(17.5),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 20,
                  color: Colors.white.withOpacity(.75),
                ),
              ),
              title: Text(formatRupiah(bloc.user.valueWrapper?.value.saldo),
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0)),
              subtitle: Text('Saldo Hexapay', style: TextStyle(fontSize: 10.0)),
            ),
          ),
          Expanded(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity(vertical: -2.5),
              leading: Container(
                width: 35,
                height: 35,
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.only(left: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(17.5),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 20,
                  color: Colors.white.withOpacity(.75),
                ),
              ),
              title: Text(formatRupiah(bloc.user.valueWrapper?.value.komisi),
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0)),
              subtitle:
                  Text('Komisi Tersedia', style: TextStyle(fontSize: 10.0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget header() {
    return Container(
      color: Colors.grey.shade200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          InkWell(
            // onTap: () async {
            //   String barcode = (await BarcodeScanner.scan()).rawContent;
            //   print(barcode);
            //   if (barcode.isNotEmpty) {
            //     return Navigator.of(context).push(
            //          MaterialPageRoute(builder: (_) => TransferByQR(barcode)));
            //   }
            // },
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => QrisPage()));
            },
            child: Container(
              width: 50.0,
              height: 50.0,
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Theme.of(context).primaryColor,
                    size: 30,
                  ),
                  Text(
                    'QRIS',
                    style: TextStyle(
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              return Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TransferManuPage(),
                ),
              );
            },
            child: Container(
              width: 50.0,
              height: 50.0,
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Column(
                children: [
                  CachedNetworkImage(
                    imageUrl: 'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2FPakeAja%2Fbussiness-and-finance.png?alt=media&token=6c649761-535b-46a5-ab69-cd42f482e3b4',
                    width: 30,
                    height: 30,
                  ),
                  Text(
                    'Transfer',
                    style: TextStyle(
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 1.0,
            height: 40.0,
            color: Colors.grey.shade400,
          ),
          Expanded(
            child: ListTile(
              dense: true,
              visualDensity: VisualDensity(vertical: -4),
              title: Text('Hexapay Point',
                  style: TextStyle(
                    fontSize: 11.0,
                  )),
              subtitle: Text(
                formatNumber(bloc.user.valueWrapper?.value.poin) + ' Pts',
                style: TextStyle(
                  fontSize: 13.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: TextButton(
                child: Text(
                  'Redeem Sekarang',
                  style: TextStyle(fontSize: 13),
                ),
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => ListReward())),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget marquee() {
    return Container(
      height: 35.0,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(0.0),
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 5,
        ),
      ),
      child: Marquee(
        text: configAppBloc.info.valueWrapper.value.marquee != null && configAppBloc.info.valueWrapper.value.marquee.message != null
            ? configAppBloc.info.valueWrapper.value.marquee.message
            : 'SEPUTAR INFO : Selalu waspada terhadap segala bentuk PENIPUAN, pihak kami tidak pernah telp / meminta kode OTP apapun. Biasakan SAVE kontak kami 08980000073 atau bisa ke LIVECHAT',
        style: TextStyle(color: Colors.white),
        blankSpace: 100,
      ),
    );
  }

  Widget bannerInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            'Hexapay Info',
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Text(
            'Lihat Info Menarik dari Hexapay Disini',
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        SizedBox(height: 10),
        CardInfo()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    print('DAN INI ADALAH HALAMAN HOME');
    return RefreshIndicator(
      onRefresh: () async {
        http.Response response = await http.get(
          Uri.parse('$apiUrl/user/info'),
          headers: {
            'Authorization': bloc.token.valueWrapper?.value,
          },
        );

        UserModel user = UserModel.fromJson(json.decode(response.body)['data']);
        bloc.user.add(user);
        setState(() {});
      },
      child: ListView(
        children: [
          topPanel(),
          header(),
          SizedBox(height: 20),
          CarouselDepan(
            viewportFraction: .65,
            aspectRatio: 3 / 1,
          ),
          MenuDepan(grid: 5, baris: 2, gradient: true),
          marquee(),
          SizedBox(height: 10),
          bannerInfo(),
          SizedBox(height: 35),
        ],
      ),
    );
  }
}
