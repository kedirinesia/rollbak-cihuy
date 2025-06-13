// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/bloc/TemplateConfig.dart';
import 'package:mobile/component/contact.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/dynamic-prepaid.dart';
import 'package:mobile/models/menu.dart';
import 'package:mobile/models/favorite_number.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/transaksi/inquiry_dynamic_prepaid.dart';
import 'package:mobile/screen/favorite-number/favorite-number.dart';
import 'package:mobile/screen/dynamic-prepaid/dynamic-denom-controller.dart';

class DynamicPrepaidDenom extends StatefulWidget {
  final MenuModel menu;

  DynamicPrepaidDenom(this.menu);

  @override
  DynamicDenomController createState() => _DynamicPrepaidDenomState();
}

class _DynamicPrepaidDenomState extends DynamicDenomController {
  bool activateContact = true;

  @override
  Widget build(BuildContext context) {
    // List<String> pkgListActivateContact = [
    //   'id.payuni.mobile',
    //   'com.tapayment.mobile',
    //   'id.popay.app',
    //   'id.ndmmobile.apk',
    //   'com.staypay.app',
    //   'id.bisabayar.app',
    //   'com.phoenixpayment.app',
    //   'com.kingreloads.app',
    //   'com.mopay.mobile',
    //   'id.funmo.mobile',
    //   'id.yukpay.mobile',
    //   'id.pmpay.mobile',
    //   'id.paymobileku.app',
    //   'com.passpay.agenpulsamurah',
    //   'id.warungpayid.mobile',
    //   'ayoba.co.id',
    //   'com.ptspayment.mobile',
    //   'id.esaldoku.mobile',
    //   'id.akupay.mobile',
    //   'id.wallpayku.apk',
    // ];

    // pkgListActivateContact.forEach((element) {
    //   if (element == packageName) {
    //     activateContact = true;
    //   }
    // });

    return Scaffold(
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
            child: Stack(children: <Widget>[
              ListView(children: <Widget>[
                Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * .2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          packageName == 'com.lariz.mobile'
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).primaryColor,
                          Theme.of(context).canvasColor
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    )),
                Container(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: packageName == 'com.eralink.mobileapk'
                            ? TextFormField(
                                  controller: tujuan,
                                  keyboardType: widget.menu.isString
                                      ? TextInputType.text
                                      : TextInputType.number,
                                  cursorColor: Theme.of(context).primaryColor,
                                  inputFormatters: [
                                    widget.menu.isString
                                        ? FilteringTextInputFormatter.allow(
                                            RegExp("[0-9a-zA-Z-_.]"))
                                        : FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Theme.of(context).primaryColor)
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Theme.of(context).primaryColor)
                                    ),
                                    isDense: true,
                                    labelText: 'Nomor Tujuan',
                                    labelStyle: TextStyle(
                                      color: Theme.of(context).secondaryHeaderColor
                                    ),
                                    prefixIcon: InkWell(
                                        child: Icon(Icons.cached, color: Theme.of(context).primaryColor,),
                                        onTap: () async {
                                          FavoriteNumberModel response =
                                              await Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    FavoriteNumber('prepaid')),
                                          );

                                          print(
                                              'response favorite-number -> $response');
                                          if (response == null) return;
                                          setState(() {
                                            tujuan.text = response.tujuan;
                                          });
                                        }),
                                    suffixIcon: InkWell(
                                        child: Icon(Icons.contacts, color: Theme.of(context).primaryColor,),
                                        onTap: () {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                                  builder: (_) => ContactPage()))
                                              .then((nomor) {
                                            if (nomor != null) {
                                              tujuan.text = nomor;
                                            }
                                          });
                                        }),
                                  ))
                            : TextFormField(
                                  controller: tujuan,
                                  keyboardType: widget.menu.isString
                                      ? TextInputType.text
                                      : TextInputType.number,
                                  inputFormatters: [
                                    widget.menu.isString
                                        ? FilteringTextInputFormatter.allow(
                                            RegExp("[0-9a-zA-Z-_.]"))
                                        : FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    labelText: 'Nomor Tujuan',
                                    prefixIcon: InkWell(
                                        child: Icon(Icons.cached),
                                        onTap: () async {
                                          FavoriteNumberModel response =
                                              await Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    FavoriteNumber('prepaid')),
                                          );

                                          print(
                                              'response favorite-number -> $response');
                                          if (response == null) return;
                                          setState(() {
                                            tujuan.text = response.tujuan;
                                          });
                                        }),
                                    suffixIcon: InkWell(
                                        child: Icon(Icons.contacts),
                                        onTap: () {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                                  builder: (_) => ContactPage()))
                                              .then((nomor) {
                                            if (nomor != null) {
                                              tujuan.text = nomor;
                                            }
                                          });
                                        }),
                                  )),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 8.0),
                          child: Container(
                              child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      layoutDenom.clear();
                                      listDenom.clear();
                                      loading = true;
                                    });
                                    getData();
                                  },
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                        packageName == 'com.lariz.mobile'
                                            ? Theme.of(context)
                                                .secondaryHeaderColor
                                            : Theme.of(context).primaryColor,
                                      ),
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white),
                                      padding: MaterialStateProperty.all<
                                              EdgeInsetsGeometry>(
                                          EdgeInsets.symmetric(
                                              horizontal: 20.0,
                                              vertical: 10.0))),
                                  icon: Icon(Icons.search),
                                  label: Text('Cari'))),
                        )
                      ],
                    )),
                loading
                    ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.white,
                              backgroundColor: packageName == 'com.lariz.mobile'
                                  ? Theme.of(context).secondaryHeaderColor
                                  : Theme.of(context).primaryColor,
                            ),
                            SizedBox(width: 20.0),
                            Text('Loading')
                          ],
                        ))
                    : Container(),
                layoutDenom.length > 0
                    ? Container(
                        child: TabBar(
                          labelPadding: EdgeInsets.all(20.0),
                          tabs: layoutDenom.map((d) {
                            return Text(d.title.toString().toUpperCase());
                          }).toList(),
                          controller: controller,
                          isScrollable: true,
                          indicatorPadding: EdgeInsets.only(top: 10.0),
                          indicatorColor: packageName == 'com.lariz.mobile'
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).primaryColor,
                          unselectedLabelColor:
                              packageName == 'com.lariz.mobile'
                                  ? Theme.of(context).secondaryHeaderColor
                                  : Theme.of(context).primaryColor,
                          labelColor: packageName == 'com.lariz.mobile'
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).primaryColor,
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          unselectedLabelStyle:
                              TextStyle(backgroundColor: Colors.white),
                        ),
                      )
                    : Container(),
                layoutDenom.length > 0
                    ? SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 10.0, bottom: 20.0, left: 10.0, right: 10.0),
                          child: Container(
                              height: MediaQuery.of(context).size.height / 2,
                              child: TabBarView(
                                children: layoutDenom.map((d) {
                                  return ListView.builder(
                                      itemCount: d.produk.length,
                                      itemBuilder: (context, index) {
                                        DynamicPrepaidDenomModel denom =
                                            d.produk[index];
                                        Color boxColor = selectedDenom != null
                                            ? selectedDenom.code == denom.code
                                                ? packageName ==
                                                        'com.lariz.mobile'
                                                    ? Theme.of(context)
                                                        .secondaryHeaderColor
                                                        .withOpacity(.8)
                                                    : Theme.of(context)
                                                        .primaryColor
                                                        .withOpacity(.8)
                                                : Colors.white
                                            : Colors.white;
                                        Color textColor = selectedDenom != null
                                            ? selectedDenom.code == denom.code
                                                ? Colors.white
                                                : Colors.grey.shade700
                                            : Colors.grey.shade700;
                                        Color priceColor = selectedDenom != null
                                            ? selectedDenom.code == denom.code
                                                ? Colors.white
                                                : Colors.green
                                            : Colors.green;
                                        return InkWell(
                                          onTap: () => selectDenom(denom),
                                          child: Container(
                                            width: double.infinity,
                                            margin:
                                                EdgeInsets.only(bottom: 10.0),
                                            decoration: BoxDecoration(
                                                color: boxColor,
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(.1),
                                                      offset: Offset(5, 10.0),
                                                      blurRadius: 20)
                                                ]),
                                            child: ListTile(
                                              leading: CircleAvatar(
                                                  foregroundColor: packageName ==
                                                          'com.lariz.mobile'
                                                      ? Theme.of(context)
                                                          .secondaryHeaderColor
                                                      : Theme.of(context)
                                                          .primaryColor,
                                                  backgroundColor: selectedDenom !=
                                                          null
                                                      ? selectedDenom.code ==
                                                              denom.code
                                                          ? Colors.white
                                                          : packageName ==
                                                                  'com.lariz.mobile'
                                                              ? Theme.of(context)
                                                                  .secondaryHeaderColor
                                                                  .withOpacity(
                                                                      .1)
                                                              : Theme.of(context)
                                                                  .primaryColor
                                                                  .withOpacity(
                                                                      .1)
                                                      : packageName ==
                                                              'com.lariz.mobile'
                                                          ? Theme.of(context)
                                                              .secondaryHeaderColor
                                                              .withOpacity(.1)
                                                          : Theme.of(context)
                                                              .primaryColor
                                                              .withOpacity(.1),
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(5.0),
                                                      child: CachedNetworkImage(imageUrl: (widget.menu.icon)))),
                                              title: Text(denom.name,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: textColor,
                                                      fontSize: 12)),
                                              subtitle: Text(
                                                  denom.description ?? '',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: textColor)),
                                              trailing: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: <Widget>[
                                                    Text(
                                                        formatRupiah(
                                                            denom.price),
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: priceColor))
                                                  ]),
                                            ),
                                          ),
                                        );
                                      });
                                }).toList(),
                                controller: controller,
                              )),
                        ),
                      )
                    : Container()
              ]),
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
                        onPressed: () async {
                          if (tujuan.text.length < 4) return;

                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => InquiryDynamicPrepaid(
                                  selectedDenom.category,
                                  widget.menu.kodeProduk,
                                  selectedDenom.code,
                                  tujuan.text)));
                        },
                      ),
              )
            ])));
  }
}
