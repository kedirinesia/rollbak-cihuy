// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile/Products/hexamobile/layout/transfer-bank/form_daftar_tranfer.dart';
import 'package:mobile/Products/hexamobile/layout/transfer-bank/transfer_bank.dart';
import 'package:mobile/models/daftar_transfer.dart';

class DaftarTransferPage extends StatefulWidget {
  const DaftarTransferPage({Key key}) : super(key: key);

  @override
  State<DaftarTransferPage> createState() => _DaftarTransferPageState();
}

class _DaftarTransferPageState extends State<DaftarTransferPage> {
  TextEditingController pencarianDaftar = TextEditingController();

    String searchString = '';
  bool isSort = false;

  void searchDaftarTransfer({String search}) {
    setState(() {
      searchString = search;
    });
  }

  // void setToFavorite(
  //     int index, bool isFavorite, DaftarTransferModel daftarTranferItem) async {
  //   print('==================================================');
  //   print(daftarTranferItem.namaRekening);
  //   print(index);

  //   if (!isFavorite)
  //     daftarTranferItem.isFavorite = false;
  //   else
  //     daftarTranferItem.isFavorite = true;

  //   await Hive.box('daftar-transfer').putAt(index, daftarTranferItem.toMap());

  //   setState(() => isSort = true);

  //   Navigator.of(context).pop();
  // }

  @override
  void dispose() {
    pencarianDaftar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            resizeToAvoidBottomInset: false,
      backgroundColor: Color(0XFFF0F0F0),
      appBar: AppBar(title: Text('Transfer'), centerTitle: true, elevation: 0),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            lastTransfer(context),
            SizedBox(height: 5),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0XFFFFFFFF),
                ),
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.height * 0.0252),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Daftar Transfer",
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.0192,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 43.0,
                      child: inputSearchDaftarTransfer(context),
                    ),
                    SizedBox(height: 10),
                    ValueListenableBuilder(
                      valueListenable: Hive.box('daftar-transfer').listenable(),
                      builder: (BuildContext context, Box<dynamic> transferItem,
                          Widget child) {
                        final daftarTransferBox =
                            Hive.box<dynamic>('daftar-transfer');
                        List values = daftarTransferBox.values.toList();

                        /* SORT BY ISFAVORITE */
                        var filtered = values
                            .where((element) => element['namaRekening']
                                .toString()
                                .toLowerCase()
                                .contains(searchString.toLowerCase()))
                            .toList();

                        // daftarTransferBox.clear();
                        if (isSort) {
                          filtered.sort((a, b) {
                            if (b['isFavorite']) {
                              return 1;
                            }
                            return -1;
                          });
                        }

                        return Expanded(
                          child: Container(
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.height *
                                          0.0012),
                              itemCount: filtered.length,
                              itemBuilder: (BuildContext context, int i) {
                                DaftarTransferModel transferItem =
                                    DaftarTransferModel.parse(filtered[i]);

                                // print(transferItem.namaRekening);
                                // print(i);

                                return Dismissible(
                                  key: ValueKey(transferItem.id),
                                  background: Container(
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(.1)),
                                  ),
                                  confirmDismiss: (direction) async {
                                    bool status = await showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (ctx) => AlertDialog(
                                                title: Text(
                                                    'Hapus Menu Favorit',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Theme.of(context)
                                                            .primaryColor)),
                                                content: Text(
                                                    'Anda yakin ingin menghapus ${transferItem.namaBank} ?',
                                                    textAlign:
                                                        TextAlign.justify),
                                                actions: [
                                                  TextButton(
                                                      child: Text(
                                                        'BATAL',
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor),
                                                      ),
                                                      onPressed: () =>
                                                          Navigator.of(ctx)
                                                              .pop(false)),
                                                  TextButton(
                                                      child: Text(
                                                        'HAPUS',
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor),
                                                      ),
                                                      onPressed: () =>
                                                          Navigator.of(ctx)
                                                              .pop(true)),
                                                ]));
                                    return status ?? false;
                                  },
                                  onDismissed: (direction) async {
                                    await Hive.box('daftar-transfer')
                                        .deleteAt(i);
                                  },
                                  child: InkWell(
                                    onTap: () => Navigator.of(context).push(
                                        PageTransition(
                                            child: TransferBankPage(
                                                transferData: transferItem),
                                            type: PageTransitionType
                                                .rippleRightUp)),
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 9),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.0580,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.0580,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              gradient: LinearGradient(
                                                begin: AlignmentDirectional
                                                    .topCenter,
                                                end: AlignmentDirectional
                                                    .bottomEnd,
                                                colors: [
                                                  Theme.of(context)
                                                      .primaryColor
                                                      .withOpacity(.1),
                                                  Theme.of(context)
                                                      .primaryColor
                                                      .withOpacity(.0),
                                                  Theme.of(context)
                                                      .primaryColor
                                                      .withOpacity(.1)
                                                ],
                                              ),
                                            ),
                                            child: CachedNetworkImage(
                                                imageUrl:
                                                    'https://ui-avatars.com/api/?name=${transferItem.namaRekening}&color=FFFFFF&background=${Theme.of(context).primaryColor.toString().substring(10, 16)}&font-size=0.33&rounded=true',
                                                fit: BoxFit.cover),
                                          ),
                                          SizedBox(width: 18),
                                          Expanded(
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.0200),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(
                                                    width: 1.0,
                                                    color: Colors.grey.shade300,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        transferItem
                                                            .namaRekening,
                                                        style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.0182,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      SizedBox(height: 6),
                                                      Text(
                                                        '${transferItem.kodeProduk} - ${transferItem.noTujuan}',
                                                        style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.0182,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 6.0),
                                                    child: Row(
                                                      children: [
                                                        transferItem.isFavorite
                                                            ? SvgPicture.asset(
                                                                'assets/img/payuni2/star2.svg',
                                                                height: 22,
                                                                width: 22,
                                                              )
                                                            : Container(),
                                                        SizedBox(width: 5),
                                                        InkWell(
                                                            onTap: () {
                                                              showModalBottomSheet(
                                                                context:
                                                                    context,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius
                                                                      .only(
                                                                          topLeft: Radius.circular(
                                                                              10.0),
                                                                          topRight:
                                                                              Radius.circular(
                                                                            10.0,
                                                                          )),
                                                                ),
                                                                isScrollControlled:
                                                                    true,
                                                                enableDrag:
                                                                    true,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return Container(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            10),
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .height *
                                                                        0.2,
                                                                    // height: MediaQuery.of(context)
                                                                    //         .size
                                                                    //         .height *
                                                                    //     0.3, // Ketika ada menu favorit
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .only(
                                                                        topLeft:
                                                                            Radius.circular(10.0),
                                                                        topRight:
                                                                            Radius.circular(10.0),
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        ListView(
                                                                      children: [
                                                                        InkWell(
                                                                          onTap:
                                                                              () async {
                                                                            bool
                                                                                status =
                                                                                await showDialog(
                                                                              context: context,
                                                                              barrierDismissible: false,
                                                                              builder: (ctx) => AlertDialog(
                                                                                title: Text('Hapus Menu Favorit', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                                                                                content: Text('Anda yakin ingin menghapus ${transferItem.namaBank} ?', textAlign: TextAlign.justify),
                                                                                actions: [
                                                                                  TextButton(
                                                                                      child: Text(
                                                                                        'BATAL',
                                                                                        style: TextStyle(color: Theme.of(context).primaryColor),
                                                                                      ),
                                                                                      onPressed: () => Navigator.of(ctx).pop(false)),
                                                                                  TextButton(
                                                                                      child: Text(
                                                                                        'HAPUS',
                                                                                        style: TextStyle(color: Theme.of(context).primaryColor),
                                                                                      ),
                                                                                      onPressed: () async {
                                                                                        await Hive.box('daftar-transfer').deleteAt(i);
                                                                                        Navigator.of(ctx).pop(true);
                                                                                        Navigator.of(context).pop();
                                                                                      }),
                                                                                ],
                                                                              ),
                                                                            );
                                                                            return status ??
                                                                                false;
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                double.infinity,
                                                                            padding:
                                                                                EdgeInsets.all(10),
                                                                            child:
                                                                                Row(children: <Widget>[
                                                                              SvgPicture.asset(
                                                                                'assets/img/payuni2/delete.svg',
                                                                                height: 25,
                                                                                width: 25,
                                                                              ),
                                                                              SizedBox(width: 10),
                                                                              Text('Hapus dari daftar'),
                                                                            ]),
                                                                          ),
                                                                        ),
                                                                        Divider(),
                                                                        InkWell(
                                                                          onTap:
                                                                              () {
                                                                            Navigator.of(context).push(PageTransition(
                                                                                child: FormDaftarTransfer(
                                                                                  transferData: transferItem,
                                                                                  indexItem: i,
                                                                                  transferBS: context,
                                                                                ),
                                                                                type: PageTransitionType.rippleRightUp));
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                double.infinity,
                                                                            padding:
                                                                                EdgeInsets.all(10),
                                                                            child:
                                                                                Row(children: <Widget>[
                                                                              SvgPicture.asset(
                                                                                'assets/img/payuni2/edit.svg',
                                                                                height: 25,
                                                                                width: 25,
                                                                              ),
                                                                              SizedBox(width: 10),
                                                                              Text('Edit'),
                                                                            ]),
                                                                          ),
                                                                        ),
                                                                        // Divider(),
                                                                        // transferItem.isFavorite
                                                                        //     ? InkWell(
                                                                        //         onTap: () => setToFavorite(i, false, transferItem),
                                                                        //         child: Container(
                                                                        //           width: double.infinity,
                                                                        //           padding: EdgeInsets.all(10),
                                                                        //           child: Row(children: <Widget>[
                                                                        //             SvgPicture.asset(
                                                                        //               'assets/img/payuni2/star.svg',
                                                                        //               height: 25,
                                                                        //               width: 25,
                                                                        //             ),
                                                                        //             SizedBox(width: 10),
                                                                        //             Text('Hapus dari Favorit'),
                                                                        //           ]),
                                                                        //         ),
                                                                        //       )
                                                                        //     : InkWell(
                                                                        //         onTap: () => setToFavorite(i, true, transferItem),
                                                                        //         child: Container(
                                                                        //           width: double.infinity,
                                                                        //           padding: EdgeInsets.all(10),
                                                                        //           child: Row(children: <Widget>[
                                                                        //             SvgPicture.asset(
                                                                        //               'assets/img/payuni2/star.svg',
                                                                        //               height: 25,
                                                                        //               width: 25,
                                                                        //             ),
                                                                        //             SizedBox(width: 10),
                                                                        //             Text('Jadikan Favorit'),
                                                                        //           ]),
                                                                        //         ),
                                                                        //       ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            child: Icon(
                                                              Icons
                                                                  .more_vert_sharp,
                                                              size: 25.0,
                                                              color: Colors.grey
                                                                  .shade600,
                                                            )),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: buttonAdd(context)),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget lastTransfer(BuildContext context) {
    return Container(
      color: Color(0XFFFFFFFF),
      padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.height * 0.0252,
          right: MediaQuery.of(context).size.height * 0.0252,
          top: MediaQuery.of(context).size.height * 0.0252,
          bottom: MediaQuery.of(context).size.height * 0.0092),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Transfer Terakhir",
            style: TextStyle(
                fontSize: MediaQuery.of(context).size.height * 0.0192,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Container(
            height: MediaQuery.of(context).size.height * 0.12,
            child: ValueListenableBuilder(
                valueListenable: Hive.box('transfer-terakhir').listenable(),
                builder: (BuildContext context, Box<dynamic> lastTransfer,
                    Widget child) {
                  return lastTransfer.isNotEmpty
                      ? ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: lastTransfer.length,
                          separatorBuilder: (_, i) => SizedBox(width: 15),
                          itemBuilder: (ctx, i) {
                            DaftarTransferModel transferItem =
                                DaftarTransferModel.parse(
                                    Hive.box('transfer-terakhir').getAt(i));
                            return Container(
                              width: 80,
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Container(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(.1),
                                      width:
                                          MediaQuery.of(context).size.height *
                                              0.0600,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.0600,
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            'https://ui-avatars.com/api/?name=Agung+Maulana&color=4F5BEB&font-size=0.33&rounded=true',
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    transferItem.namaRekening.toUpperCase(),
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.height *
                                                0.0182,
                                        fontWeight: FontWeight.w600,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    transferItem.namaBank,
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.height *
                                              0.0182,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : Center(child: Text('Transfer berlum pernah dilakukan'));
                }),
          )
        ],
      ),
    );
  }

  Widget inputSearchDaftarTransfer(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.text,
      enableInteractiveSelection: true,
      obscureText: false,
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xffF0F0F0),
        prefixIcon: Padding(
          padding: const EdgeInsetsDirectional.only(start: 13.0, end: 12.0),
          child: SvgPicture.asset(
            "assets/img/payuni2/search.svg",
            color: Colors.black,
            height: MediaQuery.of(context).size.height * 0.027,
            width: MediaQuery.of(context).size.height * 0.027,
          ), // myIcon is a 48px-wide widget.
        ),
        contentPadding:
            const EdgeInsets.only(left: 14.0, bottom: 2.0, top: 8.0),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(4),
        ),
        hintText: "Cari Daftar Transfer",
        hintStyle: TextStyle(
          fontSize: MediaQuery.of(context).size.height * 0.0182,
          color: Colors.grey,
        ),
      ),
      controller: pencarianDaftar,
      onChanged: (value) => searchDaftarTransfer(search: value),
    );
  }

  Widget buttonAdd(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(PageTransition(
            child: FormDaftarTransfer(),
            type: PageTransitionType.rippleRightUp));
      },
      style: ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all(Theme.of(context).primaryColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text(
          'Tambah Daftar Baru'.toUpperCase(),
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.height * 0.0182,
          ),
        ),
      ),
    );
  }
}
