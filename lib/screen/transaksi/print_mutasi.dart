// @dart=2.9

import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/bloc/TemplateConfig.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/mutasi.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';

class PrintMutasiPage extends StatefulWidget {
  final MutasiModel mutasi;
  PrintMutasiPage(this.mutasi);

  @override
  _PrintMutasiPageState createState() => _PrintMutasiPageState();
}

class _PrintMutasiPageState extends State<PrintMutasiPage> {
  ScreenshotController _screenshotController = ScreenshotController();
  File image;

  Future<void> share() async {
    Directory temp = await getTemporaryDirectory();
    image = await File('${temp.path}/mutasi_${widget.mutasi.id}.png').create();
    Uint8List bytes = await _screenshotController.capture(
      pixelRatio: 2.5,
      delay: Duration(milliseconds: 100),
    );
    await image.writeAsBytes(bytes);
    if (image == null) return;
    await Share.file(
      'Mutasi ${widget.mutasi.type}',
      'mutasi_${widget.mutasi.id}.png',
      image.readAsBytesSync(),
      'image/png',
    );
  }

  @override
  void initState() {
    super.initState();
    analitycs.pageView('/print/mutasi/' + widget.mutasi.id, {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Print Mutasi',
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bagikan'),
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
      body: ListView(
        padding: EdgeInsets.all(15),
        children: [
          Screenshot(
            controller: _screenshotController,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.15),
                      offset: Offset(3, 3),
                      blurRadius: 10,
                    ),
                  ]),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: configAppBloc
                              .iconApp.valueWrapper?.value['backgroundStruk'] ==
                          null
                      ? null
                      : DecorationImage(
                          image: CachedNetworkImageProvider(
                            configAppBloc
                                .iconApp.valueWrapper?.value['backgroundStruk'],
                          ),
                          repeat: ImageRepeat.repeat,
                          fit: BoxFit.scaleDown,
                        ),
                ),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white.withOpacity(.85),
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(10),
                    children: [
                      Text(
                        formatRupiah(widget.mutasi.jumlah * -1),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: packageName == 'com.lariz.mobile'
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).primaryColor,
                          fontFamily: 'Roboto Mono',
                        ),
                      ),
                      SizedBox(height: 5),
                      Center(
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.grey.withOpacity(.2),
                          ),
                          child: Text(
                            'Transfer berhasil',
                            style: TextStyle(
                              color: Colors.black.withOpacity(.65),
                              fontSize: 11,
                              fontFamily: 'Roboto Mono',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Center(
                        child: Text(
                          widget.mutasi.id.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Roboto Mono',
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      Divider(),
                      Text(
                        'RINCIAN TRANSFER',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto Mono',
                        ),
                      ),
                      Divider(),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Pengirim',
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Roboto Mono',
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            bloc.user.valueWrapper?.value.nama,
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Roboto Mono',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Nominal',
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Roboto Mono',
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            formatRupiah(widget.mutasi.jumlah * -1),
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Roboto Mono',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Sumber Dana',
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Roboto Mono',
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Saldo',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Roboto Mono',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Keterangan',
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Roboto Mono',
                              fontSize: 12,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              widget.mutasi.keterangan,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Roboto Mono',
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Divider(),
                      SizedBox(height: 5),
                      Text(
                        'Transfer via $appName',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontFamily: 'Roboto Mono',
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        formatDate(
                            widget.mutasi.created_at, 'dd MMM yyyy HH:mm'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontFamily: 'Roboto Mono',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: packageName == 'com.lariz.mobile'
            ? Theme.of(context).secondaryHeaderColor
            : Theme.of(context).primaryColor,
        child: Icon(Icons.share_rounded),
        onPressed: share,
      ),
    );
  }
}
