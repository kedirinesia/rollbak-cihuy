import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/Products/mopay/layout/components/template.dart';
import 'package:mobile/models/payment-list.dart';
import 'package:mobile/screen/topup/bank/bank.dart';
import 'package:mobile/screen/topup/channel/channel.dart';
import 'package:mobile/screen/topup/merchant/merchant.dart';
import 'package:mobile/screen/topup/qris/qris.dart';
import 'package:mobile/screen/topup/topup-controller.dart';
import 'package:mobile/screen/topup/topup.dart';
import 'package:mobile/provider/api.dart';
import 'package:mobile/screen/topup/va/va.dart';

class TopupPage extends StatefulWidget {
  @override
  _TopupPageState createState() => _TopupPageState();
}

class _TopupPageState extends State<TopupPage> with TickerProviderStateMixin {
  bool loading = true;
  List<PaymentModel> listPayment = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
    try {
      List<dynamic> datas = await api.get('/deposit/methode', cache: true);
      print(datas);
      listPayment = datas.map((e) => PaymentModel.fromJson(e)).toList();
    } catch (e) {
      listPayment = [];
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  onTapMenu(PaymentModel payment) {
    print('payment type -> ${payment.type}');
    if (payment.type == 1 || payment.type == 2) {
      return Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => TopupBank(payment)));
    } else if (payment.type == 5) {
      return Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => TopupVA()));
    } else if (payment.type == 4 || payment.type == 6) {
      return Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => TopupMerchant(payment)));
    } else if (payment.type == 7) {
      return Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => TopupChannel(payment)));
    } else if (payment.type == 8) {
      return Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => QrisTopup()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final spinkit = SpinKitThreeBounce(
      color: Theme.of(context).primaryColor,
      size: 50.0,
      controller: AnimationController(
          vsync: this, duration: const Duration(milliseconds: 1200)),
    );

    return TemplatePopay(
        title: 'Pilih Metode Pembayaran',
        height: 200.0,
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 40.0, left: 10, right: 10),
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
            ),
            child: ListView.builder(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                itemCount: listPayment.length,
                itemBuilder: (_, int index) {
                  PaymentModel mm = listPayment[index];

                  return InkWell(
                    onTap: () => onTapMenu(mm),
                    child: Container(
                      margin: EdgeInsets.only(
                          bottom: 20.0, left: 10.0, right: 10.0),
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
                        leading: CircleAvatar(
                          foregroundColor: Theme.of(context).primaryColor,
                          backgroundColor:
                              Theme.of(context).primaryColor.withOpacity(.1),
                          child: mm.icon.isNotEmpty
                              ? Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: CachedNetworkImage(
                                    imageUrl: mm.icon,
                                    width: 40.0,
                                  ))
                              : Icon(Icons.list),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(mm.title ?? ' ',
                                style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700)),
                            mm.admin != null
                                ? Text(
                                    '+${mm.admin['satuan'] == 'persen' ? '' : 'Rp '}${mm.admin['nominal']}${mm.admin['satuan'] == 'persen' ? '%' : ''} (admin)',
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey[800]),
                                  )
                                : SizedBox()
                          ],
                        ),
                        subtitle: Text(mm.description ?? ' ',
                            style: TextStyle(
                                fontSize: 10.0, color: Colors.grey.shade700)),
                      ),
                    ),
                  );
                }),
          ),
        ));
  }
}
