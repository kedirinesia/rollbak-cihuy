// @dart=2.9

import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';

class TransferGreenpay extends StatefulWidget {
  @override
  _TransferGreenpayState createState() => _TransferGreenpayState();
}

class _TransferGreenpayState extends State<TransferGreenpay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Container(
            height: 100.0,
            width: double.infinity,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: CachedNetworkImageProvider(configAppBloc
                        .iconApp.valueWrapper?.value['imageAppbar']),
                    fit: BoxFit.fill)),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              title: Text('Transfer'),
            ),
            body: ListView(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              children: [
                SizedBox(height: 20.0),
                Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(.2),
                            offset: Offset(5, 10))
                      ]),
                  child: ListTile(
                    onTap: () => Navigator.of(context).pushNamed('/transfer'),
                    leading: CircleAvatar(
                      child: CachedNetworkImage(
                          imageUrl:
                              'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Ficon.png?alt=media&token=c0006535-3e74-44fd-a322-96afb35dd1da'),
                      backgroundColor: Colors.transparent,
                    ),
                    title: Text('Transfer ke Greenpay',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: Text('Kirim Saldo ke Member Greenpay',
                        style:
                            TextStyle(fontSize: 12.0, color: Colors.grey[700])),
                    trailing: Icon(Icons.navigate_next),
                  ),
                ),
                bloc.user.valueWrapper?.value.enableWithdraw
                    ? Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 10.0,
                                  color: Colors.black.withOpacity(.2),
                                  offset: Offset(5, 10))
                            ]),
                        child: ListTile(
                          onTap: () =>
                              Navigator.of(context).pushNamed('/withdraw'),
                          leading: CircleAvatar(
                            child: CachedNetworkImage(
                                imageUrl:
                                    'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Ficon%20(1).png?alt=media&token=bef45d46-24ac-4f27-9424-8d759d5ee8f5'),
                            backgroundColor: Colors.transparent,
                          ),
                          title: Text('Transfer ke Bank',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold)),
                          subtitle: Text('Kirim Saldo ke Rekening Bank',
                              style: TextStyle(
                                  fontSize: 12.0, color: Colors.grey[700])),
                          trailing: Icon(Icons.navigate_next),
                        ),
                      )
                    : Container()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
