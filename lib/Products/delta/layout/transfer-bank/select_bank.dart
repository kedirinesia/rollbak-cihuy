// @dart=2.9
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/wd_bank.dart';
import 'package:http/http.dart' as http;

class SelectBankPage extends StatefulWidget {
  const SelectBankPage({Key key}) : super(key: key);

  @override
  State<SelectBankPage> createState() => _SelectBankPageState();
}

class _SelectBankPageState extends State<SelectBankPage> {
  List<WithdrawBankModel> _master = [];
  List<WithdrawBankModel> _banks = [];

  @override
  void initState() {
    _getBankList();
    super.initState();
  }

  Future<void> _getBankList() async {
    http.Response response = await http.get(
      Uri.parse('$apiUrl/wd/bank/list'),
      headers: {
        'Authorization': bloc.token.valueWrapper.value,
      },
    );

    if (response.statusCode == 200) {
      List<WithdrawBankModel> banks =
          (json.decode(response.body)['data'] as List)
              .map((e) => WithdrawBankModel.fromJson(e))
              .toList();

      setState(() {
        _master = banks;
        _banks = _master;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Pilih Bank',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Padding(
          //   padding: EdgeInsets.symmetric(
          //     vertical: 10,
          //     horizontal: 15,
          //   ),
          //   child: TextField(
          //     keyboardType: TextInputType.text,
          //     decoration: InputDecoration(
          //       prefixIcon: Icon(Icons.search_rounded),
          //       hintText: 'Cari Bank Tujuan',
          //       hintStyle: TextStyle(
          //         color: Colors.grey.shade500,
          //       ),
          //     ),
          //     onChanged: (value) {
          //       setState(() {
          //         _banks = _master
          //             .where((bank) =>
          //                 bank.nama.toLowerCase().contains(value.toLowerCase()))
          //             .toList();
          //       });
          //     },
          //   ),
          // ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 15),
              itemCount: _banks.length,
              separatorBuilder: (_, __) => Divider(height: 0),
              itemBuilder: (_, i) {
                WithdrawBankModel bank = _banks[i];

                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 0,
                  ),
                  title: Text(bank.nama),
                  trailing: Icon(Icons.navigate_next_rounded),
                  onTap: () => Navigator.of(context).pop(bank),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
