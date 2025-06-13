// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/ewallet-account.dart';
import 'package:mobile/models/payment-list.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/Products/eralink/layout/topup/ewallet/ewallet-controller.dart';

class TopupEwallet extends StatefulWidget {
  final PaymentModel payment;
  TopupEwallet({this.payment});
  @override
  _TopupEwalletState createState() => _TopupEwalletState();
}

class _TopupEwalletState extends EwalletController {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ewallet"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: packageName == 'com.lariz.mobile'
            ? Theme.of(context).secondaryHeaderColor
            : Theme.of(context).primaryColor,
      ),
      body: loading
          ? Container(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                  child: SpinKitThreeBounce(
                      color: packageName == 'com.lariz.mobile'
                          ? Theme.of(context).secondaryHeaderColor
                          : Theme.of(context).primaryColor,
                      size: 35)))
          : Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: SvgPicture.asset('assets/img/va.svg',
                        width: MediaQuery.of(context).size.width * .5),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .05),
                  TextFormField(
                    controller: nominal,
                    keyboardType: TextInputType.number,
                    cursorColor: Theme.of(context).primaryColor,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Nominal",
                        prefixText: "Rp ",
                        isDense: true),
                    onChanged: (value) {
                      int amount = int.tryParse(
                              nominal.text.replaceAll(RegExp('[^0-9]'), '')) ??
                          0;
                      nominal.text = FormatRupiah(amount);
                      nominal.selection = TextSelection.fromPosition(
                          TextPosition(offset: nominal.text.length));
                    },
                  ),
                  SizedBox(height: 15),
                  Divider(),
                  SizedBox(height: 15),
                  Expanded(
                    child: FutureBuilder<List<EwalletAccount>>(
                      future: getEwallet(),
                      builder: (ctx, snapshot) {
                        if (!snapshot.hasData)
                          return Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: Center(
                              child: SpinKitThreeBounce(
                                color: packageName == 'com.lariz.mobile'
                                    ? Theme.of(context).secondaryHeaderColor
                                    : Theme.of(context).primaryColor,
                                size: 25,
                              ),
                            ),
                          );

                        return ListView.separated(
                          itemCount: snapshot.data.length,
                          separatorBuilder: (_, i) => SizedBox(height: 10),
                          itemBuilder: (ctx, i) {
                            EwalletAccount channel = snapshot.data[i];

                            return Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(.2),
                                        offset: Offset(5, 10),
                                        blurRadius: 10.0)
                                  ]),
                              child: ListTile(
                                  onTap: () => topup(channel.code),
                                  dense: true,
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        packageName == 'com.lariz.mobile'
                                            ? Theme.of(context)
                                                .secondaryHeaderColor
                                                .withOpacity(.15)
                                            : Theme.of(context)
                                                .primaryColor
                                                .withOpacity(.15),
                                    child: Text(
                                      (i + 1).toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: packageName == 'com.lariz.mobile'
                                            ? Theme.of(context)
                                                .secondaryHeaderColor
                                            : Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    channel.name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: packageName == 'com.lariz.mobile'
                                          ? Theme.of(context)
                                              .secondaryHeaderColor
                                          : Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  subtitle: Text(
                                    channel.description,
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey),
                                  )),
                            );
                          },
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
