// @dart=2.9

import 'package:flutter/material.dart';

// install package
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// model
import 'package:mobile/models/kasir/listProduct.dart';

// component

// config bloc
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/provider/analitycs.dart';

// page screen
import 'package:mobile/screen/kasir/penjualan/payment.dart';
// import 'package:mobile/screen/kasir/penjualan/detailPayment.dart';

import 'package:mobile/modules.dart';

class Checkout extends StatefulWidget {
  final getData;
  List<ListProductModel> listItem;

  Checkout(this.listItem, this.getData);

  @override
  createState() => CheckoutState();
}

class CheckoutState extends State<Checkout> {
  final _formKey = GlobalKey<FormState>();
  bool loading = true;
  int totalHarga = 0;
  List<ListProductModel> itemOrders = [];

  @override
  void initState() {
    setData();
    super.initState();
    analitycs.pageView('/checkout/kasir', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Checkout Kasir',
    });
  }

  void setData() async {
    int harga = 0;
    widget.listItem.forEach((data) {
      itemOrders.add(data);
      harga += data.qty * data.hargaJual;
    });

    setState(() {
      loading = false;
      totalHarga = harga;
    });
  }

  void clearOrders() async {
    await widget.getData();
    itemOrders.clear();
    widget.listItem.clear();
    this.setData();
  }

  void submitPayment() async {
    if (itemOrders.length > 0) {
      dynamic response = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Payment(
          itemOrders,
          clearOrders,
        ),
      ));
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Pemberitahuan'),
                content: Text('Maaf Daftar Pesanan Anda Kosong'),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          iconTheme: IconThemeData(color: Colors.white),
          expandedHeight: 200.0,
          backgroundColor: Theme.of(context).primaryColor,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
              title: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Total Harga', textAlign: TextAlign.center),
                  SizedBox(height: 10.0),
                  Text('${formatNominal(totalHarga)}',
                      textAlign: TextAlign.center),
                ],
              ),
              centerTitle: true),
        ),
        SliverPadding(
          padding: EdgeInsets.all(0),
          sliver: itemOrders.length > 0
              ? SliverList(
                  delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    ListProductModel item = itemOrders[index];
                    return _buildItem(context, item);
                  },
                  childCount: itemOrders.length,
                ))
              : SliverList(
                  delegate: SliverChildListDelegate([
                    SizedBox(height: 30.0),
                    Container(
                      child: buildEmpty(),
                    ),
                  ]),
                ),
        ),
      ]),
      floatingActionButton: _buildButton(),
    );
  }

  Widget _buildButton() {
    return FloatingActionButton.extended(
      icon: Icon(Icons.payment),
      label: Text('BAYAR'),
      backgroundColor: Theme.of(context).primaryColor,
      onPressed: () => submitPayment(),
    );
  }

  Widget _buildItem(BuildContext context, ListProductModel item) {
    int totalPrice = item.qty * item.hargaJual;
    return Container(
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.1),
            blurRadius: 10.0,
            offset: Offset(5, 10),
          )
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          foregroundColor: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(.1),
          child: Text(
            '${item.namaBarang.split('')[0]}',
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),
        title: Text(item.namaBarang,
            style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700)),
        subtitle: Text(
            '${item.qty} x ${formatNominal(item.hargaJual)} = ${formatNominal(totalPrice)}',
            style: TextStyle(fontSize: 12.0, color: Colors.grey.shade700)),
      ),
    );
  }

  Widget buildEmpty() {
    return Center(
      child: SvgPicture.asset('assets/img/empty.svg',
          width: MediaQuery.of(context).size.width * .45),
    );
  }

  Widget loadingWidget() {
    return Center(
      child:
          SpinKitThreeBounce(color: Theme.of(context).primaryColor, size: 35),
    );
  }

  @override
  dispose() {
    super.dispose();
  }
}
