// @dart=2.9

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

// INSTALL PACKAGE
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/bloc/TemplateConfig.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/config.dart';

// BLOC
import '../../bloc/Bloc.dart' show bloc;
import '../../bloc/Api.dart' show apiUrl;

// MODEL
import 'package:mobile/models/menu.dart';
import 'package:mobile/models/prepaid-denom.dart';

import 'package:mobile/modules.dart';
// import 'package:mobile/component/contact.dart';
import 'package:mobile/screen/transaksi/inquiry_prepaid.dart';

class DetailDenomGrid extends StatefulWidget {
  final MenuModel menu;

  DetailDenomGrid(this.menu);

  @override
  createState() => DetailDenomGridState();
}

class DetailDenomGridState extends State<DetailDenomGrid>
    with TickerProviderStateMixin {
  List<PrepaidDenomModel> listDenom = [];
  bool loading = true;
  bool failed = false;
  PrepaidDenomModel selectedDenom;
  TextEditingController tujuan = TextEditingController();
  TextEditingController zoneID = TextEditingController();
  TextEditingController nominal = TextEditingController();

  @override
  initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      loading = true;
    });

    http.Response response = await http.get(
        Uri.parse('$apiUrl/product/${widget.menu.category_id}'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      List<PrepaidDenomModel> lm = (jsonDecode(response.body)['data'] as List)
          .map((m) => PrepaidDenomModel.fromJson(m))
          .toList();

      setState(() {
        listDenom = lm;
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
        listDenom = [];
      });
    }
  }

  onTapDenom(denom) {
    if (denom.note == 'gangguan') {
      ScaffoldMessenger.of(context).showSnackBar(
        Alert(
          'Produk sedang mengalami gangguan',
          isError: true,
        ),
      );
      return;
    }
    if (denom != null) {
      setState(() {
        selectedDenom = denom;
      });
    }
  }

  void prosesBeli(context) async {
    if (tujuan.text.length < 4) return;
    if (selectedDenom.bebas_nominal) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text('Nominal'),
          content: TextFormField(
            controller: nominal,
            keyboardType: TextInputType.number,
            autofocus: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
                prefixText: 'Rp  ',
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey))),
          ),
          actions: [
            TextButton(
                child: Text('Lanjut'.toUpperCase()),
                onPressed: () async {
                  if (nominal.text.isEmpty) return;
                  if (int.parse(nominal.text) <= 0) return;
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => InquiryPrepaid(
                            selectedDenom.kode_produk, tujuan.text,
                            nominal: int.parse(nominal.text))),
                  );
                }),
            TextButton(
                child: Text('Batal'.toUpperCase()),
                onPressed: () => Navigator.of(ctx).pop()),
          ],
        ),
      );
    } else {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) =>
              InquiryPrepaid(selectedDenom.kode_produk, tujuan.text)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.menu.name),
        centerTitle: true,
        elevation: 0,
        backgroundColor: packageName == 'com.lariz.mobile'
            ? Theme.of(context).secondaryHeaderColor
            : Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.home_rounded),
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) =>
                      configAppBloc.layoutApp?.valueWrapper?.value['home'] ??
                      templateConfig[
                          configAppBloc.templateCode.valueWrapper?.value],
                ),
                (route) => false),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    packageName == 'com.lariz.mobile'
                        ? Theme.of(context).secondaryHeaderColor
                        : Theme.of(context).primaryColor,
                    packageName == 'com.lariz.mobile'
                        ? Theme.of(context).secondaryHeaderColor.withOpacity(.2)
                        : Theme.of(context).primaryColor.withOpacity(.2),
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
                child: widget.menu.icon != null
                    ? Hero(
                        tag: 'image-icon-' + widget.menu.id,
                        child: Opacity(
                            opacity: .3,
                            child: CachedNetworkImage(
                                imageUrl: widget.menu.icon, fit: BoxFit.cover)))
                    : Container()),
            loading
                ? Container(
                    child: Center(
                      child: SpinKitThreeBounce(color: Colors.white, size: 35),
                    ),
                  )
                : ListView(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        child: TextFormField(
                          controller: tujuan,
                          keyboardType: widget.menu.isString
                              ? TextInputType.text
                              : TextInputType.number,
                          inputFormatters: [
                            widget.menu.isString
                                ? FilteringTextInputFormatter.allow(
                                    RegExp("[0-9a-zA-Z-_.#@!&*+,/?]"))
                                : FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: TextStyle(
                            fontWeight:
                                configAppBloc.boldNomorTujuan.valueWrapper.value
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'ID Game',
                          ),
                        ),
                      ),
                      loading
                          ? Container(
                              width: double.infinity,
                              height: double.infinity,
                              child: Center(
                                child: SpinKitThreeBounce(
                                    color: packageName == 'com.lariz.mobile'
                                        ? Theme.of(context).secondaryHeaderColor
                                        : Theme.of(context).primaryColor,
                                    size: 35),
                              ),
                            )
                          : Container(
                              padding: EdgeInsets.all(10.0),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                itemCount: listDenom.length,
                                itemBuilder: (ctx, i) {
                                  PrepaidDenomModel denom = listDenom[i];
                                  return buildDenom(denom);
                                },
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: (2 / 1),
                                  mainAxisSpacing: 10.0,
                                ),
                              ),
                            ),
                      SizedBox(height: 50.0),
                    ],
                  ),
            Container(
              alignment: Alignment.bottomRight,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: selectedDenom == null
                  ? null
                  : FloatingActionButton.extended(
                      backgroundColor: packageName == 'com.lariz.mobile'
                          ? Theme.of(context).secondaryHeaderColor
                          : Theme.of(context).primaryColor,
                      icon: Icon(Icons.navigate_next),
                      label: Text('Beli'),
                      onPressed: () => prosesBeli(context),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDenom(PrepaidDenomModel denom) {
    Color boxColor = selectedDenom != null
        ? selectedDenom.id == denom.id
            ? packageName == 'com.lariz.mobile'
                ? Theme.of(context).secondaryHeaderColor.withOpacity(.8)
                : Theme.of(context).primaryColor.withOpacity(.8)
            : Colors.white
        : Colors.white;
    Color textColor = selectedDenom != null
        ? selectedDenom.id == denom.id
            ? Colors.white
            : Colors.grey.shade700
        : Colors.grey.shade700;
    Color priceColor = selectedDenom != null
        ? selectedDenom.id == denom.id
            ? Colors.white
            : Colors.green
        : Colors.green;
    return GestureDetector(
      onTap: () => onTapDenom(denom),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            color: boxColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(.1),
                  offset: Offset(5, 10.0),
                  blurRadius: 20)
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              denom.nama,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 10.0),
            denom.harga_promo == null
                ? Text(
                    formatRupiah(denom.harga_jual),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: priceColor,
                    ),
                  )
                : Text(
                    formatRupiah(denom.harga_promo),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: priceColor,
                    ),
                  ),
            SizedBox(height: denom.harga_promo != null ? 3.0 : 0.0),
            denom.harga_promo != null
                ? Text(
                    formatRupiah(denom.harga_jual),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  )
                : Container(),
            SizedBox(
                height: !configAppBloc.displayGangguan.valueWrapper.value
                    ? 0
                    : denom.note.isEmpty
                        ? 0
                        : 3),
            !configAppBloc.displayGangguan.valueWrapper.value
                ? SizedBox()
                : denom.note.isEmpty
                    ? SizedBox()
                    : Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 3,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: denom.note == 'gangguan'
                              ? Colors.red.shade800
                              : denom.note == 'lambat'
                                  ? Colors.amber.shade800
                                  : Colors.green.shade800,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          denom.note.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
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
