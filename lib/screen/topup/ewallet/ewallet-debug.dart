
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/Products/payuniovo/config.dart' as payuniovoConfig;
import 'package:mobile/utils/debug_helper.dart';

class EwalletDebugHelper {
  static Future<void> debugEwalletConnection(BuildContext context) async {
    try {
      // Check token availability
      String token = bloc.token.valueWrapper?.value ?? 'NULL';
      bool hasToken = token != 'NULL' && token.isEmpty == false;
      
      DebugHelper.debugPrint('=== EWALLET DEBUG INFO ===');
      DebugHelper.debugPrint('Token available: $hasToken');
      DebugHelper.debugPrint('Token length: ${token.length}');
      DebugHelper.debugPrint('Token preview: ${token.length > 20 ? token.substring(0, 20) + '...' : token}');
      DebugHelper.debugApi('EWALLET', 'API URL: ${payuniovoConfig.apiUrl}');
      
      if (!hasToken) {
        _showDebugDialog(context, 'Token Error', 'Token tidak tersedia atau kosong. Silakan login ulang.');
        return;
      }

      // Test API connection
      DebugHelper.debugApi('EWALLET', 'Testing API connection...');
      http.Response response = await http.get(
        Uri.parse('${payuniovoConfig.apiUrl}/deposit/ewallet/list'),
        headers: {'Authorization': token}
      ).timeout(Duration(seconds: 30));

      DebugHelper.debugPrint('Response Status: ${response.statusCode}');
      DebugHelper.debugPrint('Response Headers: ${response.headers}');
      DebugHelper.debugPrint('Response Body Length: ${response.body.length}');
      DebugHelper.debugPrint('Response Body Preview: ${response.body.length > 500 ? response.body.substring(0, 500) + '...' : response.body}');

      if (response.statusCode == 200) {
        try {
          Map<String, dynamic> responseData = json.decode(response.body);
          if (responseData['data'] != null) {
            List<dynamic> datas = responseData['data'];
            DebugHelper.debugPrint('Successfully parsed ${datas.length} ewallet accounts');
            _showDebugDialog(context, 'Success', 'API berhasil diakses. Ditemukan ${datas.length} ewallet accounts.');
          } else {
            DebugHelper.debugPrint('No data field in response');
            _showDebugDialog(context, 'Warning', 'API berhasil diakses tetapi tidak ada data ewallet.');
          }
        } catch (parseError) {
          DebugHelper.debugPrint('Failed to parse response: $parseError');
          _showDebugDialog(context, 'Parse Error', 'Gagal memparse response dari server: $parseError');
        }
      } else {
        String errorMessage;
        try {
          Map<String, dynamic> errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? 'Unknown error';
        } catch (e) {
          errorMessage = 'HTTP ${response.statusCode}: ${response.body}';
        }
        
        _showDebugDialog(context, 'API Error', 'API error: $errorMessage');
      }
    } catch (e) {
      DebugHelper.debugPrint('Exception during debug: $e');
      _showDebugDialog(context, 'Exception', 'Terjadi exception: $e');
    }
  }

  static void _showDebugDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(message),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> testDepositEndpoint(BuildContext context, String ewalletCode, double nominal) async {
    try {
      String token = bloc.token.valueWrapper?.value ?? 'NULL';
      if (token == 'NULL' || token.isEmpty) {
        _showDebugDialog(context, 'Token Error', 'Token tidak tersedia untuk testing deposit.');
        return;
      }

      DebugHelper.debugPrint('=== TESTING DEPOSIT ENDPOINT ===');
      DebugHelper.debugPrint('Ewallet Code: $ewalletCode');
      DebugHelper.debugPrint('Nominal: $nominal');
      DebugHelper.debugPrint('API URL: ${payuniovoConfig.apiUrl}/deposit/ewallet');

      http.Response response = await http.post(
        Uri.parse('${payuniovoConfig.apiUrl}/deposit/ewallet'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json'
        },
        body: json.encode({'nominal': nominal, 'ewallet_code': ewalletCode})
      ).timeout(Duration(seconds: 30));

      DebugHelper.debugPrint('Deposit Response Status: ${response.statusCode}');
      DebugHelper.debugPrint('Deposit Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          Map<String, dynamic> responseData = json.decode(response.body);
          _showDebugDialog(context, 'Deposit Success', 'Deposit endpoint berhasil. Response: ${responseData.toString()}');
        } catch (e) {
          _showDebugDialog(context, 'Parse Error', 'Deposit berhasil tetapi gagal parse response: $e');
        }
      } else {
        String errorMessage;
        try {
          Map<String, dynamic> errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? 'Unknown error';
        } catch (e) {
          errorMessage = 'HTTP ${response.statusCode}: ${response.body}';
        }
        
        _showDebugDialog(context, 'Deposit Error', 'Deposit endpoint error: $errorMessage');
      }
    } catch (e) {
      DebugHelper.debugPrint('Exception during deposit test: $e');
      _showDebugDialog(context, 'Exception', 'Terjadi exception saat testing deposit: $e');
    }
  }
} 