// @dart=2.9
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/daftar_transfer.dart';
import 'package:mobile/models/postpaid.dart';
import 'package:mobile/models/wd_bank.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/kyc/verification1.dart';
import 'package:mobile/screen/transaksi/verifikasi_pin.dart';
import 'package:http/http.dart' as http;

class TransferBankPage extends StatefulWidget {
  final DaftarTransferModel transferData;

  const TransferBankPage({this.transferData});

  @override
  _TransferBankPageState createState() => _TransferBankPageState();
}

class _TransferBankPageState extends State<TransferBankPage> {
  TextEditingController noTujuan = TextEditingController();
  TextEditingController nominal = TextEditingController();
  TextEditingController namaTujuan = TextEditingController();

  WithdrawBankModel selectedBank;
  List<WithdrawBankModel> banks = [];

  PostpaidInquiryModel inq;
  bool loading = false;
  bool selectbankLoading = true;
  bool isInquiry = false;
  bool isPurchase = false;
  bool checked = false;
  bool boxFavorite = false;

  String namaBank = '';
  String kodeProduk = '';

  @override
  void initState() {
    super.initState();
    analitycs.pageView('/withdraw/', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Withdraw',
    });

    if (widget.transferData != null) {
      namaTujuan.text = widget.transferData.namaRekening;
      noTujuan.text = widget.transferData.noTujuan;
    }
  }

  @override
  void dispose() {
    noTujuan.dispose();
    nominal.dispose();
    super.dispose();
  }

  Future<void> checkNumberFavorite(String notujuan) async {
    setState(() {
      noTujuan.text = notujuan;
    });

    Map<String, dynamic> dataToSend = {'tujuan': notujuan, 'type': 'WD'};

    http.Response response =
        await http.post(Uri.parse('$apiUrl/favorite/checkNumber'),
            headers: {
              'Authorization': bloc.token.valueWrapper?.value,
              'Content-Type': 'application/json',
            },
            body: json.encode(dataToSend));

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      setState(() {
        boxFavorite = !responseData['data'];
      });
    } else {
      String message = json.decode(response.body)['message'] ??
          'Terjadi kesalahan pada server';
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              child: Text(
                'TUTUP',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      );

      setState(() {
        boxFavorite = true;
      });
    }
  }

  void inquiry() async {
    double parsedNominal = double.parse(nominal.text.replaceAll('.', ''));
    setState(() {
      isInquiry = true;
    });

    Map<String, dynamic> dataToSend = {};

    if (nominal.text.isNotEmpty && noTujuan.text.isNotEmpty) {
      print('jalan ke 1');

      if (parsedNominal < 10000) {
        String message =
            'Nominal traansfer minimal Rp 10.000 untuk melakukan withdraw';

        final snackBar = SnackBar(content: Text(message));

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          isInquiry = false;
        });
        return;
      }

      // if (bloc.user.valueWrapper?.value.saldo < (selectedBank.admin + int.parse(nominal.text)) && !isInquiry) {
      // if (!isInquiry) {
      //   String message = 'Saldo tidak mencukupi untuk melakukan withdraw';

      //   final snackBar = SnackBar(content: Text(message));

      //   ScaffoldMessenger.of(context).showSnackBar(snackBar);

      //   setState(() {
      //     isInquiry = false;
      //   });
      //   return;
      // }

      setState(() {
        loading = true;
      });

      dataToSend = {
        'kode_produk': widget.transferData.kodeProduk,
        'tujuan': noTujuan.text,
        'nominal': parsedNominal,
        'counter': 1
      };
    } else if (nominal.text.isNotEmpty &&
        noTujuan.text.isNotEmpty &&
        widget.transferData != null) {
      // print('jalan ke 2');
      // if (bloc.user.valueWrapper?.value.saldo <
      //     (selectedBank.admin + int.parse(nominal.text))) {
      //   String message = 'Saldo tidak mencukupi untuk melakukan withdraw';

      //   final snackBar = SnackBar(content: Text(message));

      //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
      //   setState(() {
      //     isInquiry = false;
      //   });
      //   return;
      // }

      // setState(() {
      //   loading = true;
      // });

      // dataToSend = {
      //   'kode_produk': widget.transferData.kodeProduk,
      //   'tujuan': noTujuan.text,
      //   'nominal': int.parse(nominal.text),
      //   'counter': 1
      // };
    } else {
      setState(() {
        isInquiry = false;
      });
      return;
    }

    http.Response response =
        await http.post(Uri.parse('$apiUrl/trx/postpaid/inquiry'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': bloc.token.valueWrapper?.value
            },
            body: json.encode(dataToSend));
    // print("RESPONSE");
    // print(response.body);

    if (response.statusCode == 200) {
      await checkNumberFavorite(noTujuan.text);
      Map<String, dynamic> data = json.decode(response.body)['data'];
      inq = PostpaidInquiryModel.fromJson(data);
      checked = true;
    } else {
      String message = json.decode(response.body)['message'] ??
          'Terjadi kesalahan saat mengambil data dari server';

      final snackBar = SnackBar(content: Text(message));

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    setState(() {
      isInquiry = false;
      loading = false;
    });
  }

  void purchase() async {
    setState(() {
      isPurchase = true;
    });

    if (!bloc.user.valueWrapper.value.kyc_verification) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text('Transaksi Gagal'),
          content: Text(
              'Akun anda belum diverifikasi, transaksi dibatalkan. Silahkan verifikasi akun untuk dapat menikmati fitur tarik saldo',
              textAlign: TextAlign.justify),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'TUTUP',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      );
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => SubmitKyc1()));
      return;
    }

    // if ((inq.admin + int.parse(nominal.text)) < 10000) {
    //   String message =
    //       'Nominal traansfer minimal Rp 10.000 untuk melakukan withdraw';

    //   final snackBar = SnackBar(content: Text(message));

    //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
    //   setState(() {
    //     isInquiry = false;
    //   });
    //   return;
    // }

    String pin = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => VerifikasiPin()));
    if (pin == null) return;

    setState(() {
      loading = true;
    });
    sendDeviceToken();
    double parsedNominal = double.parse(nominal.text.replaceAll('.', ''));
    http.Response response = await http.post(
        Uri.parse('$apiUrl/trx/postpaid/purchase'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bloc.token.valueWrapper?.value
        },
        body: json
            .encode({'tracking_id': inq.trackingId, 'nominal': parsedNominal}));

    if (response.statusCode == 200) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                  title: Text('Berhasil'),
                  content: Text(
                      'Transaksi sedang di proses, anda dapat melihat status transaksi di riwayat transaksi'),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text('TUTUP'))
                  ]));
      nominal.clear();
      // bank.clear();
      noTujuan.clear();
      selectedBank = null;
      inq = null;
      checked = false;

      Map<String, dynamic> dataToSend = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'kodeProduk': widget.transferData.kodeProduk,
        'namaRekening': widget.transferData.namaRekening,
        'namaBank': widget.transferData.namaBank,
        'noTujuan': widget.transferData.noTujuan,
      };

      bool dataExists = false;

      Hive.box('transfer-terakhir').values.forEach((el) {
        DaftarTransferModel tranfer = DaftarTransferModel.parse(el);

        if (tranfer.namaRekening == dataToSend['namaRekening']) {
          dataExists = true;
        }
      });

      if (!dataExists) {
        DaftarTransferModel tranfer = DaftarTransferModel.parse(dataToSend);

        Hive.box('transfer-terakhir')
            .add(DaftarTransferModel.create(tranfer).toMap());
      }
      Navigator.of(context).pop();
    } else {
      String message = json.decode(response.body)['message'] ??
          'Terjadi kesalahan saat mengambil data dari server';

      final snackBar = SnackBar(content: Text(message));

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    setState(() {
      loading = false;
      isPurchase = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0XFFF0F0F0),
        appBar: AppBar(
            title: Text(!checked ? 'Transfer' : 'Konfirmasi Transfer'),
            centerTitle: true,
            elevation: 0),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: loading
                        ? Container(
                            width: double.infinity,
                            height: double.infinity,
                            padding: EdgeInsets.all(20),
                            child: Center(
                                child: SpinKitThreeBounce(
                                    color: Theme.of(context).primaryColor,
                                    size: 35)))
                        : !checked
                            ? Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 15),
                                    selectBank(context),
                                    SizedBox(height: 10),
                                    inputDestionationNumber(context),
                                    SizedBox(height: 10),
                                    inputNominalTransfer(context),
                                    SizedBox(height: 15),
                                  ],
                                ),
                              )
                            : ListView(
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ListView(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          children: <Widget>[
                                            SizedBox(height: 15),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Detail Transfer',
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SvgPicture.asset(
                                                  "assets/img/payuni2/receipt.svg",
                                                  color: Colors.black,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.027,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.027,
                                                ),
                                              ],
                                            ),
                                            Divider(),
                                            Text('Nomor Rekening',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 11)),
                                            SizedBox(height: 5),
                                            Text(inq.noPelanggan,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            SizedBox(height: 10),
                                            Text('Nama Pemilik',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 11)),
                                            SizedBox(height: 5),
                                            Text(inq.nama,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            SizedBox(height: 10),
                                            Text('Nominal',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 11)),
                                            SizedBox(height: 5),
                                            Text(formatRupiah(inq.tagihan),
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            SizedBox(height: 10),
                                            Text('Admin',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 11)),
                                            SizedBox(height: 5),
                                            Text(formatRupiah(inq.admin),
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            SizedBox(height: 10),
                                            Text('Cashback',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 11)),
                                            SizedBox(height: 5),
                                            Text(formatRupiah(inq.fee),
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            SizedBox(height: 5),
                                            Divider(),
                                            SizedBox(height: 5),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text('Total Bayar',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(formatRupiah(inq.total),
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.green,
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ],
                                            ),
                                            SizedBox(height: 20),
                                            Column(
                                              children: [
                                                Container(
                                                  width: double.infinity,
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      color: inq.total >
                                                              bloc
                                                                  .saldo
                                                                  .valueWrapper
                                                                  .value
                                                          ? Colors.red
                                                              .withOpacity(.1)
                                                          : Theme.of(context)
                                                              .primaryColor
                                                              .withOpacity(.1),
                                                      border: Border.all(
                                                        color: inq.total >
                                                                bloc
                                                                    .saldo
                                                                    .valueWrapper
                                                                    .value
                                                            ? Colors.red
                                                                .withOpacity(.1)
                                                            : Theme.of(context)
                                                                .primaryColor
                                                                .withOpacity(
                                                                    .1),
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Text('Saldo Anda',
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .grey)),
                                                          Text(
                                                            formatRupiah(bloc
                                                                .saldo
                                                                .valueWrapper
                                                                .value),
                                                            style: TextStyle(
                                                                color: inq.total >
                                                                        bloc
                                                                            .saldo
                                                                            .valueWrapper
                                                                            .value
                                                                    ? Colors.red
                                                                    : Theme.of(
                                                                            context)
                                                                        .primaryColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                inq.total >
                                                        bloc.saldo.valueWrapper
                                                            .value
                                                    ? Container(
                                                        child: Center(
                                                          child: Text(
                                                            'Maaf Saldo anda tidak mencukupi !',
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox(),
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                  ),
                ),
                submitWithdrawButton(context),
              ]),
        ));
  }

  Widget selectBank(value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(.15),
          child: SvgPicture.asset('assets/img/payuni2/bank.svg'),
        ),
        title: Text(
          'Bank Tujuan',
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(widget.transferData.namaBank),
      ),
    );
  }

  Widget inputDestionationNumber(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nomor Tujuan',
              style: TextStyle(color: Colors.grey, fontSize: 11)),
          SizedBox(height: 5),
          TextFormField(
            enableInteractiveSelection: true,
            obscureText: false,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xffF0F0F0),
              prefixIcon: Padding(
                padding:
                    const EdgeInsetsDirectional.only(start: 13.0, end: 12.0),
                child: SvgPicture.asset(
                  "assets/img/payuni2/credit_card.svg",
                  color: Colors.black,
                  height: MediaQuery.of(context).size.height * 0.027,
                  width: MediaQuery.of(context).size.height * 0.027,
                ),
              ),
              contentPadding:
                  const EdgeInsets.only(left: 14.0, bottom: 2.0, top: 8.0),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(4),
              ),
              hintText: "Nomor Rekening Tujuan",
              hintStyle: TextStyle(
                fontSize: MediaQuery.of(context).size.height * 0.0182,
                color: Colors.grey,
              ),
            ),
            controller: noTujuan,
          ),
        ],
      ),
    );
  }

  Widget inputDestionationName(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Text('Nama Tujuan',
              style: TextStyle(color: Colors.grey, fontSize: 11)),
          SizedBox(height: 5),
          TextFormField(
            enableInteractiveSelection: true,
            obscureText: false,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xffF0F0F0),
              prefixIcon: Padding(
                padding:
                    const EdgeInsetsDirectional.only(start: 13.0, end: 12.0),
                child: SvgPicture.asset(
                  "assets/img/payuni2/user.svg",
                  color: Colors.black,
                  height: MediaQuery.of(context).size.height * 0.027,
                  width: MediaQuery.of(context).size.height * 0.027,
                ),
              ),
              contentPadding:
                  const EdgeInsets.only(left: 14.0, bottom: 2.0, top: 8.0),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(4),
              ),
              hintText: "Nama Rekening Tujuan",
              hintStyle: TextStyle(
                fontSize: MediaQuery.of(context).size.height * 0.0182,
                color: Colors.grey,
              ),
            ),
            controller: namaTujuan,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.height * 0.027,
            ),
          ),
        ],
      ),
    );
  }

  Widget inputNominalTransfer(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nominal Transfer',
              style: TextStyle(color: Colors.grey, fontSize: 11)),
          SizedBox(height: 5),
          TextFormField(
            enableInteractiveSelection: true,
            obscureText: false,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              int amount =
                  int.tryParse(nominal.text.replaceAll(RegExp('[^0-9]'), '')) ??
                      0;
              nominal.text = FormatRupiah(amount);
              nominal.selection = TextSelection.fromPosition(
                  TextPosition(offset: nominal.text.length));
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xffF0F0F0),
              prefixIcon: Padding(
                padding:
                    const EdgeInsetsDirectional.only(start: 13.0, end: 12.0),
                child: SvgPicture.asset(
                  "assets/img/payuni2/receipt.svg",
                  color: Colors.black,
                  height: MediaQuery.of(context).size.height * 0.027,
                  width: MediaQuery.of(context).size.height * 0.027,
                ),
              ),
              contentPadding:
                  const EdgeInsets.only(left: 14.0, bottom: 2.0, top: 8.0),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(4),
              ),
              hintText: "Nominal Transfer",
              hintStyle: TextStyle(
                fontSize: MediaQuery.of(context).size.height * 0.0182,
                color: Colors.grey,
              ),
            ),
            controller: nominal,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.height * 0.027,
            ),
          ),
        ],
      ),
    );
  }

  Widget submitWithdrawButton(BuildContext context) {
    if (!isInquiry) {
      if (isPurchase) {
        return Container(
          padding: EdgeInsets.all(10),
          width: double.infinity,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor, backgroundColor: Theme.of(context).primaryColor, disabledForegroundColor: Theme.of(context).primaryColor.withOpacity(0.38), disabledBackgroundColor: Theme.of(context).primaryColor.withOpacity(0.12),
            ),
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                'TRANSFER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.height * 0.0182,
                ),
              ),
            ),
          ),
        );
      }

      if (inq != null) {
        if (inq.total > bloc.saldo.valueWrapper.value) {
          return Container(
            padding: EdgeInsets.all(10),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor, backgroundColor: Theme.of(context).primaryColor, disabledForegroundColor: Theme.of(context).primaryColor.withOpacity(0.38), disabledBackgroundColor: Theme.of(context).primaryColor.withOpacity(0.12),
              ),
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  'TRANSFER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.height * 0.0182,
                  ),
                ),
              ),
            ),
          );
        }
      }

      return Container(
        padding: EdgeInsets.all(10),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: checked ? purchase : inquiry,
          style: ElevatedButton.styleFrom(
            foregroundColor: Theme.of(context).primaryColor, backgroundColor: Theme.of(context).primaryColor, disabledForegroundColor: Theme.of(context).primaryColor.withOpacity(0.38), disabledBackgroundColor: Theme.of(context).primaryColor.withOpacity(0.12),
          ),
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              checked ? 'TRANSFER' : 'LANJUTKAN',
              style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.height * 0.0182,
              ),
            ),
          ),
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.all(10),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            foregroundColor: Theme.of(context).primaryColor, backgroundColor: Theme.of(context).primaryColor, disabledForegroundColor: Theme.of(context).primaryColor.withOpacity(0.38), disabledBackgroundColor: Theme.of(context).primaryColor.withOpacity(0.12),
          ),
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              'LANJUTKAN',
              style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.height * 0.0182,
              ),
            ),
          ),
        ),
      );
    }
  }
}
