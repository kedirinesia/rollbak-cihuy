import 'package:flutter/material.dart';

// MODEL
import 'package:mobile/models/mp_voucher.dart';

import 'package:mobile/modules.dart';

class DetailVoucher extends StatefulWidget {
  VoucherMarket voucher;

  DetailVoucher(this.voucher);
  @override
  createState() => DetailVoucherState();
}

class DetailVoucherState extends State<DetailVoucher> {
  @override
  initState() {
    super.initState();
  }

  void submitVoucher() async {
    Navigator.of(context).pop(widget.voucher);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0.0, centerTitle: true, title: Text(widget.voucher.title)),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(20.0),
        child: MaterialButton(
          onPressed: () => submitVoucher(),
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
          child: Text('Gunakan'),
        ),
      ),
      body: Container(
        child: ListView(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.voucher.title,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).primaryColor),
                  ),
                  SizedBox(height: 10.0),
                  ListTile(
                    leading: Icon(
                      Icons.schedule,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text(
                      'Berlaku Hingga',
                    ),
                    trailing: Container(
                      padding: EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.red.withOpacity(0.3),
                      ),
                      child: Text(
                        formatDate(widget.voucher.endDate, "d MMMM yyyy") ??
                            ' ',
                        style: TextStyle(
                          color: Colors.red.withOpacity(0.8),
                          fontSize: 13.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.0),
                  ListTile(
                    leading: Icon(
                      Icons.monetization_on,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text(
                      'Minimal Transaksi',
                    ),
                    trailing: Text(
                      '${formatRupiah(widget.voucher.minNominal)}',
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.0),
                  ListTile(
                    leading: Icon(
                      Icons.money,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text(
                      'Nominal Voucher',
                    ),
                    trailing: Text(
                      '${formatRupiah(widget.voucher.nominalVoucher)}',
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Divider(),
                  SizedBox(height: 10.0),
                  Text(widget.voucher.description),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  dispose() {
    super.dispose();
  }
}
