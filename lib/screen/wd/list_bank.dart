// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/wd_bank.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/config.dart';

class WithdrawBankPage extends StatefulWidget {
  @override
  _WithdrawBankPageState createState() => _WithdrawBankPageState();
}

class _WithdrawBankPageState extends State<WithdrawBankPage> {
    List<WithdrawBankModel> banks = [];
  List<WithdrawBankModel> filtered = [];
  bool isLoading = true;

  @override
  void initState() {
    getList();
    super.initState();
    analitycs.pageView('/list/bank/', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'List Bank',
    });
  }

  Future<void> getList() async {
    setState(() {
      isLoading = true;
    });

    http.Response response = await http.get(Uri.parse('$apiUrl/wd/bank/list'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      banks.clear();
      filtered.clear();
      datas.forEach((el) => banks.add(WithdrawBankModel.fromJson(el)));
      filtered.addAll(banks);
    } else {
      String message = json.decode(response.body)['message'] ??
          'Terjadi kesalahan saat mengambil data dari server';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
                appBar:
            AppBar(title: Text('Daftar Bank'), centerTitle: true, elevation: 0),
        body: Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.all(20),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  packageName == 'com.eralink.mobileapk'
                    ? TextFormField(
                      keyboardType: TextInputType.text,
                      cursorColor: Theme.of(context).primaryColor,
                      decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).primaryColor)
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).primaryColor)
                          ),
                          isDense: true,
                          icon: Icon(Icons.search, color: Theme.of(context).primaryColor,),
                          hintText: 'Cari Bank',
                          hintStyle: TextStyle(
                            color: Theme.of(context).secondaryHeaderColor
                          )),
                      onChanged: (value) {
                        filtered = banks
                            .where((el) => el.nama
                                .toString()
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();

                        setState(() {});
                      })
                    : TextFormField(
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              isDense: true,
                              icon: Icon(Icons.search),
                              hintText: 'Cari Bank'),
                          onChanged: (value) {
                            filtered = banks
                                .where((el) => el.nama
                                    .toString()
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();

                            setState(() {});
                          }),
                  SizedBox(height: 20),
                  Flexible(
                      flex: 1,
                      child: isLoading
                          ? Container(
                              width: double.infinity,
                              height: double.infinity,
                              padding: EdgeInsets.all(15),
                              child: Center(
                                  child: SpinKitThreeBounce(
                                      color: Theme.of(context).primaryColor,
                                      size: 35)))
                          : banks.length == 0
                              ? Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  padding: EdgeInsets.all(15),
                                  child: Center(
                                      child: Text('TIDAK ADA DATA',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor))))
                              : ListView.builder(
                                  itemCount: filtered.length,
                                  itemBuilder: (_, i) {
                                    WithdrawBankModel bank = filtered[i];

                                    return ListTile(
                                      dense: true,
                                      onTap: () =>
                                          Navigator.of(context).pop(bank),
                                      contentPadding: EdgeInsets.all(0),
                                      title: Text(bank.nama,
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                      subtitle: Text(bank.description,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11)),
                                    );
                                  }))
                ])));
  }
}
