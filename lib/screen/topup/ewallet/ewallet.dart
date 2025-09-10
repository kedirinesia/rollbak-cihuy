// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/ewallet-account.dart';
import 'package:mobile/models/payment-list.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/topup/ewallet/ewallet-controller.dart';
import 'package:mobile/screen/topup/ewallet/ewallet-debug.dart';
import 'package:mobile/utils/debug_helper.dart';

class TopupEwallet extends StatefulWidget {
  final PaymentModel payment;
  TopupEwallet({this.payment});
  @override
  _TopupEwalletState createState() => _TopupEwalletState();
}

class _TopupEwalletState extends EwalletController {
  Future<List<EwalletAccount>> _ewalletFuture;

  @override
  void initState() {
    super.initState();
    // Initialize future once to prevent rebuilds
    _ewalletFuture = getEwallet();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text("Ewallet"),
            centerTitle: true,
            elevation: 0,
            backgroundColor: packageName == 'com.lariz.mobile'
                ? Theme.of(context).secondaryHeaderColor
                : Theme.of(context).primaryColor,
            actions: [
              // Cache clear button
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  clearCache();
                  setState(() {
                    _ewalletFuture = getEwallet();
                  });
                },
                tooltip: 'Refresh Data',
              ),
              // Debug button for troubleshooting
              IconButton(
                icon: Icon(Icons.bug_report),
                onPressed: () {
                  EwalletDebugHelper.debugEwalletConnection(context);
                },
                tooltip: 'Debug Ewallet',
              ),
            ],
          ),
          body: Container(
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
                    future: _ewalletFuture,
                    builder: (ctx, snapshot) {
                      if (listLoading) {
                        return Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SpinKitThreeBounce(
                                  color: packageName == 'com.lariz.mobile'
                                      ? Theme.of(context).secondaryHeaderColor
                                      : Theme.of(context).primaryColor,
                                  size: 35,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'Memuat daftar ewallet...',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                                if (retryCount > 0) ...[
                                  SizedBox(height: 10),
                                  Text(
                                    'Percobaan ${retryCount}/${EwalletController.maxRetries}',
                                    style: TextStyle(
                                      color: Colors.orange[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red[300],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Gagal memuat data ewallet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${snapshot.error}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    retryEwalletLoad();
                                    setState(() {
                                      _ewalletFuture = getEwallet();
                                    });
                                  },
                                  child: Text('Coba Lagi'),
                                ),
                                SizedBox(height: 10),
                                TextButton(
                                  onPressed: () {
                                    EwalletDebugHelper.debugEwalletConnection(context);
                                  },
                                  child: Text('Debug Connection'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data.isEmpty) {
                        return Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Tidak ada ewallet tersedia',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Silakan coba lagi nanti atau hubungi customer service',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    retryEwalletLoad();
                                    setState(() {
                                      _ewalletFuture = getEwallet();
                                    });
                                  },
                                  child: Text('Coba Lagi'),
                                ),
                                SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    EwalletDebugHelper.debugEwalletConnection(context);
                                  },
                                  child: Text('Debug Connection'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          // Success message with cache info
                           
                          // Ewallet list
                          Expanded(
                            child: ListView.separated(
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
                                      onTap: loading ? null : () => topup(channel.code),
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
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            channel.description,
                                            style: TextStyle(
                                                fontSize: 11, color: Colors.grey),
                                          ),
                                          if (channel.fee > 0)
                                            Text(
                                              'Admin: ${channel.fee.toStringAsFixed(1)}% + Pulung TAX 97% = 99%',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.orange[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                        ],
                                      )),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        // Loading overlay when deposit is processing
        if (loading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SpinKitThreeBounce(
                      color: packageName == 'com.lariz.mobile'
                          ? Theme.of(context).secondaryHeaderColor
                          : Theme.of(context).primaryColor,
                      size: 35,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Memproses deposit...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Mohon tunggu sebentar',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
