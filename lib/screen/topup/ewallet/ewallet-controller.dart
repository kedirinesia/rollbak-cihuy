// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/deposit_link.dart';
import 'package:mobile/models/ewallet-account.dart';
import 'package:mobile/screen/topup/ewallet/ewallet.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/utils/debug_helper.dart';

abstract class EwalletController extends State<TopupEwallet> {
  bool loading = false;
  bool listLoading = false;
  int retryCount = 0;
  static const int maxRetries = 3;
  TextEditingController nominal = TextEditingController();
  
  // Cache untuk mencegah infinite loop
  List<EwalletAccount> _cachedEwalletList;
  bool _hasCachedData = false;
  DateTime _lastFetchTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
  }

  // Check if cache is still valid
  bool get _isCacheValid {
    if (_lastFetchTime == null || _cachedEwalletList == null) return false;
    return DateTime.now().difference(_lastFetchTime) < _cacheValidDuration;
  }

  Future<List<EwalletAccount>> getEwallet() async {
    // Return cached data if available and valid
    if (_hasCachedData && _isCacheValid && _cachedEwalletList != null) {
      DebugHelper.debugPrint('Returning cached ewallet data (${_cachedEwalletList.length} accounts)');
      return _cachedEwalletList;
    }

    // Check if token is available
    if (bloc.token.valueWrapper?.value == null || bloc.token.valueWrapper?.value.isEmpty) {
      DebugHelper.debugPrint('ERROR: Token is null or empty');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token tidak tersedia, silakan login ulang'))
      );
      return [];
    }

    // Check retry count to prevent infinite loops
    if (retryCount >= maxRetries) {
      DebugHelper.debugPrint('ERROR: Max retries reached, stopping ewallet fetch');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data setelah ${maxRetries} percobaan. Silakan coba lagi nanti.'))
      );
      retryCount = 0; // Reset for next attempt
      return [];
    }

    setState(() {
      listLoading = true;
    });

    try {
      DebugHelper.debugPrint('Fetching ewallet list... (Attempt ${retryCount + 1})');
      DebugHelper.debugPrint('API URL: $apiUrl/deposit/ewallet/list');
      DebugHelper.debugPrint('Token: ${bloc.token.valueWrapper?.value.substring(0, 20)}...');

      http.Response response = await http.get(
        Uri.parse('$apiUrl/deposit/ewallet/list'),
        headers: {'Authorization': bloc.token.valueWrapper?.value}
      ).timeout(Duration(seconds: 30));

      DebugHelper.debugPrint('Response status: ${response.statusCode}');
      DebugHelper.debugPrint('Response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        try {
          Map<String, dynamic> responseData = json.decode(response.body);
          if (responseData['data'] != null) {
            List<dynamic> datas = responseData['data'];
            List<EwalletAccount> ewalletList = [];
            
            // Parse each ewallet account individually to handle partial failures
            for (int i = 0; i < datas.length; i++) {
              try {
                EwalletAccount account = EwalletAccount.fromJson(datas[i]);
                ewalletList.add(account);
              } catch (parseError) {
                DebugHelper.debugPrint('ERROR: Failed to parse ewallet account at index $i: $parseError');
                DebugHelper.debugPrint('ERROR: Data: ${datas[i]}');
                // Continue with other accounts instead of failing completely
              }
            }
            
            if (ewalletList.isNotEmpty) {
              DebugHelper.debugPrint('Successfully parsed ${ewalletList.length}/${datas.length} ewallet accounts');
              
              // Cache the successful result
              _cachedEwalletList = ewalletList;
              _hasCachedData = true;
              _lastFetchTime = DateTime.now();
              retryCount = 0; // Reset retry count on success
              
              DebugHelper.debugPrint('Data cached successfully');
              return ewalletList;
            } else {
              DebugHelper.debugPrint('ERROR: No ewallet accounts could be parsed');
              retryCount++;
              return [];
            }
          } else {
            DebugHelper.debugPrint('ERROR: No data field in response');
            retryCount++;
            return [];
          }
        } catch (parseError) {
          DebugHelper.debugPrint('ERROR: Failed to parse response: $parseError');
          DebugHelper.debugPrint('ERROR: Response body preview: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
          retryCount++;
          return [];
        }
      } else {
        DebugHelper.debugPrint('ERROR: API returned status ${response.statusCode}');
        DebugHelper.debugPrint('ERROR: Response body: ${response.body}');
        
        // Try to parse error message
        try {
          Map<String, dynamic> errorData = json.decode(response.body);
          String errorMessage = errorData['message'] ?? 'Terjadi kesalahan pada server';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage))
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Terjadi kesalahan pada server (Status: ${response.statusCode})'))
          );
        }
        retryCount++;
        return [];
      }
    } catch (e) {
      DebugHelper.debugPrint('ERROR: Exception during API call: $e');
      retryCount++;
      
      if (retryCount < maxRetries) {
        DebugHelper.debugPrint('Retrying in 2 seconds... (${retryCount}/${maxRetries})');
        await Future.delayed(Duration(seconds: 2));
        return getEwallet(); // Retry
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil data ewallet setelah ${maxRetries} percobaan'))
        );
        return [];
      }
    } finally {
      setState(() {
        listLoading = false;
      });
    }
  }

  void topup(String ewalletCode) async {
    // Check if token is available
    if (bloc.token.valueWrapper?.value == null || bloc.token.valueWrapper?.value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token tidak tersedia, silakan login ulang'))
      );
      return;
    }

    if (nominal.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Nominal belum diisi')));
      return;
    }

    double parsedNominal;
    try {
      parsedNominal = double.parse(nominal.text.replaceAll('.', ''));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Format nominal tidak valid')));
      return;
    }

    if (parsedNominal < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Minimal deposit adalah Rp 10.000')));
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      DebugHelper.debugPrint('Making ewallet deposit request...');
      DebugHelper.debugPrint('API URL: $apiUrl/deposit/ewallet');
      DebugHelper.debugPrint('Nominal: $parsedNominal');
      DebugHelper.debugPrint('Ewallet Code: $ewalletCode');

      http.Response response = await http.post(
        Uri.parse('$apiUrl/deposit/ewallet'),
        headers: {
          'Authorization': bloc.token.valueWrapper?.value,
          'Content-Type': 'application/json'
        },
        body: json.encode({'nominal': parsedNominal, 'ewallet_code': ewalletCode})
      ).timeout(Duration(seconds: 30));

      DebugHelper.debugPrint('Deposit response status: ${response.statusCode}');
      DebugHelper.debugPrint('Deposit response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          DepositLink link = DepositLink.fromJson(json.decode(response.body));
          Navigator.of(context).pop();

          try {
            await launch(link.url,
                customTabsOption: CustomTabsOption(
                    toolbarColor: packageName == 'com.lariz.mobile'
                        ? Theme.of(context).secondaryHeaderColor
                        : Theme.of(context).primaryColor,
                    enableDefaultShare: false,
                    enableUrlBarHiding: true,
                    showPageTitle: true,
                    animation: CustomTabsSystemAnimation.slideIn()));
          } catch (e) {
            DebugHelper.debugPrint('ERROR: Failed to launch URL: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal membuka halaman pembayaran'))
            );
          }
        } catch (parseError) {
          DebugHelper.debugPrint('ERROR: Failed to parse deposit response: $parseError');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memproses response dari server'))
          );
        }
      } else {
        String message;
        try {
          Map<String, dynamic> errorData = json.decode(response.body);
          message = errorData['message'] ?? 'Terjadi masalah pada server';
        } catch (e) {
          message = 'Terjadi masalah pada server (Status: ${response.statusCode})';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message))
        );
      }
    } catch (e) {
      DebugHelper.debugPrint('ERROR: Exception during deposit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal melakukan deposit: ${e.toString()}'))
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  // Method to reset retry count and retry loading
  void retryEwalletLoad() {
    retryCount = 0;
    _hasCachedData = false; // Clear cache to force fresh fetch
    _cachedEwalletList = null;
    setState(() {}); // This will trigger a rebuild and retry
  }

  // Method to clear cache
  void clearCache() {
    _hasCachedData = false;
    _cachedEwalletList = null;
    _lastFetchTime = null;
    DebugHelper.debugPrint('Ewallet cache cleared');
  }
}
