// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:mobile/Products/stokpay/layout/components/banner.dart';
import 'package:mobile/Products/stokpay/layout/mutasi.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/component/rewards.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/profile/cs/cs.dart';
import 'package:mobile/screen/transfer_saldo/transfer_saldo.dart';
import '../../../component/card_info.dart';
import 'package:mobile/Products/stokpay/layout/components/menudepan.dart';

class Home2App extends StatefulWidget {
  @override
  _Home2AppState createState() => _Home2AppState();
}

class _Home2AppState extends State<Home2App>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: Duration(seconds: 4), vsync: this);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: <Widget>[
          // Container(
          //   width: double.infinity,
          //   height: MediaQuery.of(context).size.height / 4.8,
          //   decoration: BoxDecoration(
          //     borderRadius: new BorderRadius.only(
          //       bottomLeft: Radius.elliptical(30, 28),
          //       bottomRight: Radius.elliptical(30, 28),
          //     ),
          //     gradient: LinearGradient(
          //         colors: [
          //           Theme.of(context).primaryColor,
          //           Theme.of(context).primaryColor.withOpacity(.8),
          //         ],
          //         begin: AlignmentDirectional.topCenter,
          //         end: AlignmentDirectional.bottomCenter),
          //   ),
          // ),
          Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 15),
                    child: Text(
                      bloc.username.valueWrapper?.value,
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                // padding: EdgeInsets.only(left: 10),
                                margin: EdgeInsets.only(left: 15),
                                child: Text('Rp',
                                    style: TextStyle(
                                        fontSize: 12.0, color: Colors.black)),
                              ),
                              SizedBox(width: 5.0),
                              Text(
                                formatNumber(bloc.saldo.valueWrapper?.value),
                                style: TextStyle(
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              AnimatedBuilder(
                                animation: animationController,
                                builder: (BuildContext context, Widget child) {
                                  return RotationTransition(
                                      turns: animationController,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.refresh,
                                          color: Colors.black,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          animationController.fling().then((a) {
                                            animationController.value = 0;
                                          });

                                          updateUserInfo();
                                          setState(() {});
                                        },
                                      ));
                                },
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 15),
                            child: Text(
                              formatNumber(bloc.user.valueWrapper?.value.poin) +
                                  ' Poin',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          InkWell(
                            onTap: () =>
                                Navigator.of(context).pushNamed('/topup'),
                            child: Container(
                              margin: EdgeInsets.only(right: 15),
                              padding: EdgeInsets.symmetric(
                                horizontal: 25,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).primaryColor,
                                    Theme.of(context).secondaryHeaderColor,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0XFFff5555),
                                    offset: Offset(3, 3),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Text(
                                'Top Up',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  MenuGrid(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.1),
                          blurRadius: 10.0,
                          offset: Offset(10, 5),
                        ),
                      ],
                    ),
                    child: MenuDepan(grid: 5, gradient: true),
                  ),
                  SizedBox(height: 20.0),
                  CarouselDepan(),
                  SizedBox(height: 20.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Info',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Mengenal Lebih Jauh Aplikasi ${configAppBloc.namaApp.valueWrapper?.value}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  CardInfo(),
                  SizedBox(height: 20.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Hadiah',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Hadiah unggulan dari ${configAppBloc.namaApp.valueWrapper?.value}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  RewardComponent(),
                ],
              ))
        ],
      ),
    );
  }
}

class MenuGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      padding: EdgeInsets.all(13),
      decoration: BoxDecoration(
        // color: Theme.of(context).primaryColor,
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).secondaryHeaderColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Color(0XFFff5555),
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(.5),
            offset: Offset(5, 5),
            blurRadius: 25,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          InkWell(
            onTap: () => Navigator.of(context).pushNamed('/withdraw'),
            child: Container(
              padding: EdgeInsets.all(0.0),
              child: Column(
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(.1),
                          Colors.transparent,
                          Theme.of(context).primaryColor.withOpacity(.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.all(8),
                    child: CachedNetworkImage(
                      imageUrl: 'http://img.stokpay.com/iconapp/wd1.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    'Transfer',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              return Navigator.of(context).push(
                PageTransition(
                  child: TransferSaldo(''),
                  type: PageTransitionType.rippleRightUp,
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(0.0),
              child: Column(
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(.1),
                          Colors.transparent,
                          Theme.of(context).primaryColor.withOpacity(.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.all(8),
                    child: CachedNetworkImage(
                      imageUrl: 'http://img.stokpay.com/iconapp/tf2.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    'Kirim Saldo',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MutasiPage(),
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(0.0),
              child: Column(
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(.1),
                          Colors.transparent,
                          Theme.of(context).primaryColor.withOpacity(.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.all(8),
                    child: CachedNetworkImage(
                      imageUrl: 'http://img.stokpay.com/iconapp/reward2.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    'Mutasi',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () => Navigator.of(context).pushNamed('/komisi'),
            child: Container(
              padding: EdgeInsets.all(0.0),
              child: Column(
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(.1),
                          Colors.transparent,
                          Theme.of(context).primaryColor.withOpacity(.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.all(8),
                    child: CachedNetworkImage(
                      imageUrl: 'http://img.stokpay.com/iconapp/komisi3.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    'Komisi',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              return Navigator.of(context).push(
                PageTransition(
                  child: CS(),
                  type: PageTransitionType.rippleRightUp,
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(0.0),
              child: Column(
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.all(8),
                    child: CachedNetworkImage(
                      imageUrl: 'http://img.stokpay.com/iconapp/cs3.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    'Bantuan',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
