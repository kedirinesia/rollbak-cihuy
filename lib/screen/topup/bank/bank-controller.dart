// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/screen/topup/bank/bank.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/screen/topup/bank/transfer-deposit.dart';
import '../../../bloc/Bloc.dart' show bloc;
import '../../../bloc/Api.dart' show apiUrl;
import 'package:mobile/utils/debug_helper.dart';

abstract class BankController extends State<TopupBank> {
  bool loading = false;
  TextEditingController nominal = TextEditingController();

  void topup() async {
    DebugHelper.debugPrint('🔍 [TOPUP BANK CTRL] topup() called');
    DebugHelper.debugPrint('🔍 [TOPUP BANK CTRL] Raw nominal text: ${nominal.text}');
    
    double parsedNominal = double.parse(nominal.text.replaceAll('.', ''));
    DebugHelper.debugPrint('🔍 [TOPUP BANK CTRL] Parsed nominal: $parsedNominal');
    DebugHelper.debugPrint('🔍 [TOPUP BANK CTRL] Payment type: ${widget.payment.type}');
    
    if (nominal.text.isEmpty) {
      DebugHelper.debugPrint('🔍 [TOPUP BANK CTRL] Validation failed: nominal empty');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Nominal belum diisi')));
      return;
    } else if (parsedNominal < 10000) {
      DebugHelper.debugPrint('🔍 [TOPUP BANK CTRL] Validation failed: nominal < 10000');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Minimal deposit adalah Rp 10.000')));
      return;
    }
    
    DebugHelper.debugPrint('🔍 [TOPUP BANK CTRL] Validation passed');

    DebugHelper.debugPrint('🔍 [TOPUP BANK CTRL] Setting loading to true');
    setState(() {
      loading = true;
    });

    var requestUrl = apiUrl + '/deposit/send';
    var requestHeaders = {
      'content-type': 'application/json',
      'Authorization': bloc.token.valueWrapper?.value
    };
    var requestBody = {'nominal': parsedNominal, 'type': widget.payment.type};
    
    DebugHelper.debugPrint('🔍 [TOPUP BANK CTRL] FULL API REQUEST DETAILS:');
    DebugHelper.debugPrint('🔍 [TOPUP BANK CTRL] URL: $requestUrl');
    DebugHelper.debugPrint('🔍 [TOPUP BANK CTRL] Headers: ${requestHeaders.toString()}');
    DebugHelper.debugPrint('🔍 [TOPUP BANK CTRL] Body: ${requestBody.toString()}');
    DebugHelper.debugPrint('🔍 [TOPUP BANK CTRL] Body JSON: ${jsonEncode(requestBody)}');
    
    http.Response response = await http.post(
        Uri.parse(requestUrl),
        headers: requestHeaders,
        body: jsonEncode(requestBody));

    DebugHelper.debugPrint('🔍 [TOPUP BANK CTRL] API response status: ${response.statusCode}');
    DebugHelper.debugPrint('🔍 [TOPUP BANK CTRL] FULL API RESPONSE PAYLOAD:');
    DebugHelper.debugPrint('🔍 [TOPUP BANK CTRL] ${response.body}');
    
    if (response.statusCode == 200) {
      DebugHelper.debugPrint('🔍 [TOPUP BANK CTRL] API request successful');
      var responseData = jsonDecode(response.body);
      DebugHelper.debugPrint('🔍 [TOPUP BANK CTRL] FULL PARSED RESPONSE DATA:');
      DebugHelper.debugPrint('🔍 [TOPUP BANK CTRL] ${responseData.toString()}');
      
      var data = responseData['data'];
      DebugHelper.debugPrint('🔍 [TOPUP BANK CTRL] Transfer data: ${data.toString()}');
      DebugHelper.debugPrint('🔍 [TOPUP BANK CTRL] Nominal transfer: ${data['nominal_transfer']}');
      DebugHelper.debugPrint('🔍 [TOPUP BANK CTRL] Navigating to TransferDepositPage');
      
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => TransferDepositPage(
              data['nominal_transfer'], widget.payment.type)));
    } else {
      DebugHelper.debugPrint('🔍 [TOPUP BANK CTRL] API request failed');
      var errorData = json.decode(response.body);
      DebugHelper.debugPrint('🔍 [TOPUP BANK CTRL] Error response: ${errorData.toString()}');
      
      String message = errorData['message'] ??
          'Terjadi kesalahan pada server';
      DebugHelper.debugPrint('🔍 [TOPUP BANK CTRL] Error message: $message');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }

    DebugHelper.debugPrint('🔍 [TOPUP BANK CTRL] Setting loading to false');
    setState(() {
      loading = false;
    });
    DebugHelper.debugPrint('🔍 [TOPUP BANK CTRL] State updated');
  }
  }

