// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/utils/debug_helper.dart';
// Date formatting is available in modules.dart
import 'package:mobile/models/trx.dart';

class PulsaHistoryPage extends StatefulWidget {
  @override
  _PulsaHistoryPageState createState() => _PulsaHistoryPageState();
}

class _PulsaHistoryPageState extends State<PulsaHistoryPage> {
  List<TrxModel> allTransactions = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  // Kategori pulsa payuni yang diminta
  final List<String> pulsaCategoryIds = [
    '5eb704e9c78b532302ab4118',
    '5eb704e8c78b53b66cab40d9',
    '5eb704e8c78b534178ab3f52',
    '5eb704e8c78b536e52ab4029',
    '607aef122e7b75785eeaa909',
    '5eb704e8c78b5348f8ab3f86',
    '5eb704e9c78b535885ab413e',
  ];

  @override
  void initState() {
    super.initState();
    _fetchPulsaHistory();
  }

  Future<void> _fetchPulsaHistory() async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
      allTransactions.clear();
    });

    DebugHelper.debugPrint('=== PAYUNIOVO PULSA HISTORY FETCH START ===');
    DebugHelper.debugPrint('Fetching data for ${pulsaCategoryIds.length} category IDs');
    DebugHelper.debugPrint('Category IDs: $pulsaCategoryIds');

    try {
      // Fetch data dari setiap category ID
      for (String categoryId in pulsaCategoryIds) {
        await _fetchDataForCategory(categoryId);
      }

      // Sort transaksi berdasarkan tanggal terbaru
      allTransactions.sort((a, b) {
        try {
          DateTime dateTimeA = DateTime.parse(a.created_at);
          DateTime dateTimeB = DateTime.parse(b.created_at);
          return dateTimeB.compareTo(dateTimeA);
        } catch (e) {
          DebugHelper.debugPrint('Error sorting dates: $e');
          return 0;
        }
      });

      DebugHelper.debugPrint('=== PAYUNIOVO PULSA HISTORY FETCH COMPLETE ===');
      DebugHelper.debugPrint('Total transactions found: ${allTransactions.length}');

    } catch (e) {
      DebugHelper.debugPrint('=== PAYUNIOVO PULSA HISTORY FETCH ERROR ===');
      DebugHelper.debugPrint('Error: $e');
      
      setState(() {
        hasError = true;
        errorMessage = 'Gagal mengambil data history pulsa: $e';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchDataForCategory(String categoryId) async {
    try {
      String apiEndpoint = 'https://payuni-app.findig.id/api/v1/trx/lastTransaction?kategori_id=$categoryId&limit=1000&skip=0';
      
      DebugHelper.debugPrint('🌐 Fetching category ID: $categoryId');
      DebugHelper.debugPrint('🌐 API Endpoint: $apiEndpoint');

      final response = await http.get(
        Uri.parse(apiEndpoint),
        headers: {
          'Authorization': bloc.token.valueWrapper?.value ?? '',
        },
      );

      DebugHelper.debugPrint('📡 Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        List<dynamic> datas;
        
        try {
          dynamic responseData = json.decode(response.body);
          
          if (responseData is List) {
            datas = responseData;
          } else if (responseData is Map<String, dynamic>) {
            datas = responseData['data'] ?? [];
          } else {
            datas = [];
          }
          
          // Filter hanya transaksi pulsa yang sukses
          List<TrxModel> categoryTransactions = datas
              .map((e) => TrxModel.fromJson(e))
              .where((trx) => 
                  trx.status == 2 && // Status sukses
                  trx.tujuan.isNotEmpty &&
                  (trx.tujuan.startsWith('08') || trx.tujuan == '4321') && // Nomor pulsa
                  _isPulsaTransaction(trx) // Pastikan ini transaksi pulsa
              )
              .toList();

          allTransactions.addAll(categoryTransactions);
          
          DebugHelper.debugPrint('✅ Category $categoryId: Found ${categoryTransactions.length} pulsa transactions');
          
        } catch (jsonError) {
          DebugHelper.debugPrint('❌ JSON Parse Error for category $categoryId: $jsonError');
          DebugHelper.debugPrint('❌ Response body: ${response.body}');
        }
        
      } else {
        DebugHelper.debugPrint('❌ HTTP Error for category $categoryId: ${response.statusCode}');
        DebugHelper.debugPrint('❌ Response body: ${response.body}');
      }
      
    } catch (error) {
      DebugHelper.debugPrint('❌ Exception for category $categoryId: $error');
    }
  }

  bool _isPulsaTransaction(TrxModel trx) {
    // Cek apakah ini transaksi pulsa berdasarkan keterangan atau produk
    String keterangan = trx.keterangan?.toLowerCase() ?? '';
    String produkName = '';
    
    // Cek dari produk jika ada
    if (trx.produk != null && trx.produk is Map) {
      produkName = (trx.produk['name'] ?? '').toString().toLowerCase();
    }
    
    return keterangan.contains('pulsa') || 
           produkName.contains('pulsa') ||
           keterangan.contains('top up') ||
           produkName.contains('top up');
  }

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return formatDate(date.toIso8601String(), 'dd MMM yyyy, HH:mm');
    } catch (e) {
      return dateString;
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Processing';
      case 2:
        return 'Success';
      case 3:
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History Pulsa Payuni'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchPulsaHistory,
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitFadingCircle(
                    color: Colors.blue,
                    size: 50.0,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Mengambil data history pulsa...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Terjadi Kesalahan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _fetchPulsaHistory,
                        child: Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : allTransactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Belum Ada History Pulsa',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'History transaksi pulsa akan muncul di sini',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchPulsaHistory,
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: allTransactions.length,
                        itemBuilder: (context, index) {
                          TrxModel transaction = allTransactions[index];
                          
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(transaction.status),
                                child: Icon(
                                  Icons.phone_android,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                transaction.tujuan ?? 'Unknown',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text(
                                    transaction.keterangan ?? 'Pulsa',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    _formatDate(transaction.created_at),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Rp ${transaction.harga_jual?.toString() ?? '0'}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(transaction.status),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getStatusText(transaction.status),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                // Bisa ditambahkan detail transaksi jika diperlukan
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Detail transaksi: ${transaction.id}'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
