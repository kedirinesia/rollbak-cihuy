// @dart=2.9

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:mobile/Products/eazyin/layout/components/carousel_depan.dart';
import 'package:mobile/Products/eazyin/layout/home_model.dart';
import 'package:mobile/Products/eazyin/layout/components/menu_depan.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/Products/maripay/layout/card_info.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/component/rewards.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/profile/print_settings.dart';
import 'package:mobile/screen/transfer_saldo/transfer_by_qr.dart';
import 'package:mobile/Products/eazyin/layout/withdraw.dart';

class Home4App extends StatefulWidget {
  @override
  _Home4AppState createState() => _Home4AppState();
}

class _Home4AppState extends Home4Model {
  AnimationController _animationController;

  DateTime currentBackPressTime;

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Apakah anda yakin?'),
              content: Text('Anda ingin keluar dari aplikasi'),
              actions: <Widget>[
                TextButton(
                  child: Text('Tidak'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text('Ya'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                )
              ],
            );
          },
        ) ??
        false;
  }

  @override
  void initState() {
    _animationController =
        AnimationController(duration: Duration(seconds: 3), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget marquee() {
    return Container(
      padding: EdgeInsets.all(3),
      color: Theme.of(context).primaryColor,
      height: 21,
      width: double.infinity,
      // child: Center(
      //   child: Marquee(
      //     text: configAppBloc.info.valueWrapper?.value.marquee != null
      //         ? configAppBloc.info.valueWrapper?.value.marquee.message
      //         : 'SEPUTAR INFO : Selalu waspada terhadap segala bentuk PENIPUAN, pihak kami tidak pernah telp / meminta kode OTP apapun. Jika terjadi masalah bisa ke menu Customer Service atau bisa ke LIVECHAT',
      //     style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      //     scrollAxis: Axis.horizontal,
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     blankSpace: 100,
      //     velocity: 100.0,
      //     pauseAfterRound: Duration(seconds: 1),
      //     startPadding: 10.0,
      //     accelerationDuration: Duration(seconds: 1),
      //     accelerationCurve: Curves.linear,
      //     decelerationDuration: Duration(milliseconds: 1000),
      //     decelerationCurve: Curves.easeOut,
      //   ),
      // ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            ListView(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: 70.0,
                  margin: EdgeInsets.only(top: 215.0),
                  child: Container(
                    padding: EdgeInsets.only(left: 10.0, top: 40.0),
                    // margin: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.5),
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          tileMode: TileMode.clamp,
                          colors: <Color>[
                            Theme.of(context).primaryColor,
                            Colors.purpleAccent[700]
                          ],
                        )),
                    height: 120,
                  ),
                ),
                SizedBox(height: 20),
                MenuDepan(grid: 5, baris: 2),
                RewardComponent(),
                CardInfo(),
                SizedBox(height: 10.0),
                // CarouselDepan(),
                SizedBox(height: 20.0),
              ],
            ),
            Container(
                width: double.infinity,
                height: 80.0,
                margin: EdgeInsets.only(
                    top: 214.0), // Rubah sementara, default 200.0
                child: Container(
                  padding: EdgeInsets.only(left: 20.0, top: 40.0),
                  // margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        tileMode: TileMode.clamp,
                        colors: <Color>[
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(.4)
                        ],
                      )),
                  height: 160,
                )),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0)),
                  color: Colors.white),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.0),
                    CarouselDepan(marginBottom: 0.0),
                    SizedBox(height: 10.0),
                    marquee(),
                    Container(
                      padding: EdgeInsets.only(top: 0.0, bottom: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Container(
                                child: Row(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(top: 10.0),
                                  child: AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) =>
                                        RotationTransition(
                                      turns: _animationController,
                                      child: IconButton(
                                          icon: Icon(Icons.refresh, size: 30.0),
                                          color: Theme.of(context).primaryColor,
                                          onPressed: () async {
                                            try {
                                              _animationController
                                                  .fling()
                                                  .then((a) {
                                                _animationController.value = 0;
                                              });

                                              await updateUserInfo();

                                              showToast(context,
                                                  'Berhasil memperbarui saldo');

                                              setState(() {});
                                            } catch (e) {
                                              showToast(context,
                                                  'Gagal memperbarui saldo');
                                            }
                                          }),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 0.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                          'Hi ${bloc.username.valueWrapper?.value.split(' ')[0]}',
                                          style: TextStyle(fontSize: 10.0)),
                                      SizedBox(height: 5.0),
                                      Text(
                                          formatNominal(
                                              bloc.saldo.valueWrapper?.value),
                                          style: TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          'Poin ' +
                                              formatNominal(bloc
                                                  .poin.valueWrapper?.value),
                                          style: TextStyle(fontSize: 10.0))
                                    ],
                                  ),
                                )
                              ],
                            )),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.only(top: 20.0, left: 10.0),
                          //   child: InkWell(
                          //     onTap: () =>
                          //         Navigator.of(context).pushNamed('/withdraw'),
                          //     child: Column(
                          //       crossAxisAlignment: CrossAxisAlignment.center,
                          //       children: <Widget>[
                          //         SizedBox(height: 5.0),
                          //         Icon(Icons.call_missed_outgoing,
                          //             color: Colors.black, size: 20.0),
                          //         SizedBox(height: 5.0),
                          //         Text('Withdraw',
                          //             style: TextStyle(
                          //                 fontSize: 10.0, color: Colors.black))
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          SizedBox(width: 20.0),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 5.0, left: 10.0),
                            child: InkWell(
                              onTap: () =>
                                  Navigator.of(context).pushNamed('/myqr'),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(height: 5.0),
                                  CachedNetworkImage(
                                    imageUrl:
                                        'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/assets%2Ficons%2Fqr-code.png?alt=media&token=a2d4ead5-b4ed-498d-861b-1f9f92ba1a94',
                                    width: 20,
                                  ),
                                  SizedBox(height: 5.0),
                                  Text(
                                    'My QR',
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 20.0),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 5.0, left: 10.0),
                            child: InkWell(
                              onTap: () =>
                                  Navigator.of(context).pushNamed('/topup'),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(height: 5.0),
                                  Image.asset('assets/img/money.png',
                                      fit: BoxFit.cover, width: 20.0),
                                  SizedBox(height: 5.0),
                                  Text('Topup',
                                      style: TextStyle(
                                          fontSize: 10.0, color: Colors.black))
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 20.0),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 5.0, left: 10.0),
                            child: InkWell(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => WithdrawPage(),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(height: 5.0),
                                  CachedNetworkImage(
                                    imageUrl:
                                        'https://dokumen.payuni.co.id/logo/eazyin/tf.png',
                                    width: 20,
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Text('Transfer Bank',
                                      style: TextStyle(
                                          fontSize: 10.0, color: Colors.black))
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 5.0, left: 10.0),
                            child: InkWell(
                              onTap: () => showModalBottomSheet(
                                  context: context,
                                  builder: (context) => PanelSemuaMenu()),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(height: 5.0),
                                  Icon(Icons.list,
                                      color: Theme.of(context).primaryColor),
                                  SizedBox(height: 5.0),
                                  Text('Semua',
                                      style: TextStyle(
                                          fontSize: 10.0, color: Colors.black))
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0),
                        ],
                      ),
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}

class PanelSemuaMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
      child: GridView(
        shrinkWrap: true,
        primary: false,
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          Container(
            // color: Colors.red.withOpacity(.1),
            child: InkWell(
              onTap: () async {
                String barcode = (await BarcodeScanner.scan()).toString();
                print(barcode);
                if (barcode.isNotEmpty) {
                  return Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => TransferByQR(barcode)));
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: LinearGradient(
                          begin: AlignmentDirectional.topCenter,
                          end: AlignmentDirectional.bottomEnd,
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(.1),
                            Theme.of(context).primaryColor.withOpacity(.1),
                            Theme.of(context).primaryColor.withOpacity(.1)
                          ]),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: CachedNetworkImage(
                        imageUrl:
                            'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/assets%2Ficons%2Fqr-code-scan.png?alt=media&token=e6b8db9f-d654-4d81-8437-29e91009e636',
                        width: 40.0,
                        fit: BoxFit.cover),
                  ),
                  SizedBox(height: 10.0),
                  Flexible(
                    child: Text(
                      'Scan',
                      style: TextStyle(
                          fontSize: 10.0,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.bold),
                      softWrap: true,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            // color: Colors.red.withOpacity(.1),
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PrintSettingsPage(),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: LinearGradient(
                          begin: AlignmentDirectional.topCenter,
                          end: AlignmentDirectional.bottomEnd,
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(.1),
                            Theme.of(context).primaryColor.withOpacity(.1),
                            Theme.of(context).primaryColor.withOpacity(.1)
                          ]),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.print_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Flexible(
                    child: Text(
                      'Atur Printer',
                      style: TextStyle(
                          fontSize: 10.0,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.bold),
                      softWrap: true,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            // color: Colors.red.withOpacity(.1),
            child: InkWell(
              onTap: () => Navigator.of(context).pushNamed('/transfer'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: LinearGradient(
                          begin: AlignmentDirectional.topCenter,
                          end: AlignmentDirectional.bottomEnd,
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(.1),
                            Theme.of(context).primaryColor.withOpacity(.1),
                            Theme.of(context).primaryColor.withOpacity(.1)
                          ]),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: CachedNetworkImage(
                        imageUrl:
                            'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/assets%2Ficons%2Ftransfer%20(1).png?alt=media&token=ebd17176-58cf-4b5a-870e-88f718f1b192',
                        width: 40.0,
                        fit: BoxFit.cover),
                  ),
                  SizedBox(height: 10.0),
                  Flexible(
                    child: Text(
                      'Transfer Saldo',
                      style: TextStyle(
                          fontSize: 10.0,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.bold),
                      softWrap: true,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 5,
            childAspectRatio: 0.8,
            mainAxisSpacing: 10.0),
      ),
    );
  }
}
