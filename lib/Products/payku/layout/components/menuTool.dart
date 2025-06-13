// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/Products/payku/layout/transfer.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/history/history.dart';

class MenuTools extends StatefulWidget {
  @override
  _MenuToolsState createState() => _MenuToolsState();
}

class _MenuToolsState extends State<MenuTools> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushNamed('/topup');
              },
              child: Row(
                children: [
                  Container(
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color:
                                Theme.of(context).primaryColor.withOpacity(.1),
                          ),
                          margin:
                              const EdgeInsets.only(left: 15.0, right: 12.0),
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            "assets/img/payuni2/wallet.svg",
                            color: Theme.of(context).primaryColor,
                            width: 22,
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  formatRupiah(
                                      bloc.user.valueWrapper?.value.saldo),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 2.0),
                                Text(
                                  'Topup Saldo',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 10.0),
            width: 1.5,
            height: 32.0,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => HistoryPage()));
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).primaryColor.withOpacity(.1),
                    ),
                    margin: const EdgeInsets.only(right: 10.0),
                    padding: const EdgeInsets.all(7.0),
                    child: SvgPicture.asset(
                      "assets/img/payuni2/receipt-time.svg",
                      color: Theme.of(context).primaryColor,
                      width: 22,
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        'Riwayat',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        'Pesanan',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                topRight: Radius.circular(10.0),
                              ),
                            ),
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.17,
                                padding: EdgeInsets.symmetric(
                                  vertical: 13,
                                  horizontal: 20,
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 4,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[400],
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                      child: GridView(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        padding: EdgeInsets.all(0),
                                        children: [
                                          Container(
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        TransferPagePopay(),
                                                  ),
                                                );
                                              },
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Container(
                                                    width: 40,
                                                    height: 40,
                                                    padding: EdgeInsets.all(8),
                                                    child: SvgPicture.asset(
                                                      'assets/img/payuni2/send.svg',
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2),
                                                  Text(
                                                    'Transfer Saldo',
                                                    style: TextStyle(
                                                      fontSize: 10.0,
                                                      color:
                                                          Colors.grey.shade800,
                                                    ),
                                                    softWrap: true,
                                                    textAlign: TextAlign.center,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            child: InkWell(
                                              onTap: () => Navigator.of(context)
                                                  .pushNamed('/myqr'),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Container(
                                                    width: 40,
                                                    height: 40,
                                                    padding: EdgeInsets.all(8),
                                                    child: SvgPicture.asset(
                                                      'assets/img/payuni2/accept.svg',
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2),
                                                  Text(
                                                    'Terima Saldo',
                                                    style: TextStyle(
                                                      fontSize: 10.0,
                                                      color:
                                                          Colors.grey.shade800,
                                                    ),
                                                    softWrap: true,
                                                    textAlign: TextAlign.center,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 5,
                                          crossAxisSpacing: 10,
                                          childAspectRatio: .95,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10.0),
                          child: Icon(
                            Icons.more_vert,
                            color:
                                Theme.of(context).primaryColor.withOpacity(.5),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class MenuGrid extends StatelessWidget {
  final String imageUrl;
  final String label;

  MenuGrid({this.imageUrl, this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        child: Column(
          children: <Widget>[
            CachedNetworkImage(imageUrl: imageUrl),
            SizedBox(height: 5.0),
            Text(label ?? '-',
                style: TextStyle(fontSize: 10.0, color: Colors.white))
          ],
        ),
      ),
    );
  }
}
