
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'dart:convert';
import 'package:mobile/models/deposit.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/Products/seepays/layout/deposit/deposit.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Bloc.dart' show bloc;
import 'package:mobile/bloc/Api.dart' show apiUrl;
import 'package:mobile/utils/debug_helper.dart';

abstract class DepositController extends State<DepositPage> {
  bool loadingNewPage = false;
  bool loading = true;
  bool isEdge = false;
  int limit = 20;
  int currentPage = 0;
  List<DepositModel> listDeposit = [];

  @override
  void initState() {
    super.initState();
    DebugHelper.debugPrint('🔍 [DEPOSIT] initState called');
    DebugHelper.debugPrint('🔍 [DEPOSIT] User ID: ${bloc.userId.valueWrapper?.value}');
    DebugHelper.debugPrint('🔍 [DEPOSIT] Auto reload enabled: ${configAppBloc.autoReload.valueWrapper?.value}');
    
    var analyticsData = {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'History Deposit'
    };
    DebugHelper.debugPrint('🔍 [DEPOSIT] Analytics payload: ${analyticsData.toString()}');
    analitycs.pageView('/history/deposit', analyticsData);
    DebugHelper.debugPrint('🔍 [DEPOSIT] Analytics page view sent');

    if (configAppBloc.autoReload.valueWrapper?.value ?? false) {
      DebugHelper.debugPrint('🔍 [DEPOSIT] Setting up periodic timer for auto reload');
      Timer.periodic(new Duration(seconds: 1), (timer) {
        DebugHelper.debugPrint('🔍 [DEPOSIT] Auto reload timer triggered');
        getData();
      });
    } else {
      DebugHelper.debugPrint('🔍 [DEPOSIT] Auto reload disabled, calling getData once');
      getData();
    }
  }

  getData() async {
    DebugHelper.debugPrint('🔍 [DEPOSIT] getData() called');
    DebugHelper.debugPrint('🔍 [DEPOSIT] Current page: $currentPage, Limit: $limit, Is edge: $isEdge');
    
    if (isEdge) {
      DebugHelper.debugPrint('🔍 [DEPOSIT] Reached edge, returning early');
      return;
    }
    
    var requestUrl = '$apiUrl/deposit/list?page=$currentPage&limit=$limit';
    var requestHeaders = {'Authorization': bloc.token.valueWrapper?.value};
    
    DebugHelper.debugPrint('🔍 [DEPOSIT] FULL API REQUEST DETAILS:');
    DebugHelper.debugPrint('🔍 [DEPOSIT] URL: $requestUrl');
    DebugHelper.debugPrint('🔍 [DEPOSIT] Headers: ${requestHeaders.toString()}');
    DebugHelper.debugPrint('🔍 [DEPOSIT] Token: ${bloc.token.valueWrapper?.value?.substring(0, 20)}...');
    
    http.Response response = await http.get(
        Uri.parse(requestUrl),
        headers: requestHeaders);

    DebugHelper.debugPrint('🔍 [DEPOSIT] API response status: ${response.statusCode}');
    DebugHelper.debugPrint('🔍 [DEPOSIT] API response body length: ${response.body.length}');
    DebugHelper.debugPrint('🔍 [DEPOSIT] FULL API RESPONSE PAYLOAD:');
    DebugHelper.debugPrint('🔍 [DEPOSIT] ${response.body}');

    if (response.statusCode == 200) {
      DebugHelper.debugPrint('🔍 [DEPOSIT] API request successful');
      var responseData = jsonDecode(response.body);
      DebugHelper.debugPrint('🔍 [DEPOSIT] FULL PARSED RESPONSE DATA:');
      DebugHelper.debugPrint('🔍 [DEPOSIT] ${responseData.toString()}');
      
      List<dynamic> list = responseData['data'] as List;
      DebugHelper.debugPrint('🔍 [DEPOSIT] Received ${list.length} deposit items');
      
      if (list.length == 0) {
        DebugHelper.debugPrint('🔍 [DEPOSIT] No more data, setting isEdge to true');
        isEdge = true;
      }
      
      DebugHelper.debugPrint('🔍 [DEPOSIT] Current listDeposit length before adding: ${listDeposit.length}');
      list.forEach((item) {
        DebugHelper.debugPrint('🔍 [DEPOSIT] Processing deposit item: ${item.toString().substring(0, 100)}...');
        listDeposit.add(DepositModel.fromJson(item));
      });
      DebugHelper.debugPrint('🔍 [DEPOSIT] ListDeposit length after adding: ${listDeposit.length}');
      
      currentPage++;
      DebugHelper.debugPrint('🔍 [DEPOSIT] Incremented currentPage to: $currentPage');
    } else {
      DebugHelper.debugPrint('🔍 [DEPOSIT] API request failed with status: ${response.statusCode}');
      DebugHelper.debugPrint('🔍 [DEPOSIT] Error response: ${response.body}');
    }

    if (this.mounted) {
      DebugHelper.debugPrint('🔍 [DEPOSIT] Widget is mounted, updating state');
      setState(() {
        loading = false;
      });
      DebugHelper.debugPrint('🔍 [DEPOSIT] State updated, loading set to false');
    } else {
      DebugHelper.debugPrint('🔍 [DEPOSIT] Widget not mounted, skipping setState');
    }
  }
}
