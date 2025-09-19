// @dart=2.9
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/models/pulsa.dart';
import 'package:mobile/screen/pulsa/pulsa.dart';
import 'package:http/http.dart' as http;
import '../../bloc/Bloc.dart' show bloc;
import '../../bloc/Api.dart' show apiUrl;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mobile/utils/debug_helper.dart';

abstract class PulsaController extends State<Pulsa>
    with TickerProviderStateMixin {
  List<PulsaModel> listDenom = [];
  bool loading = false;
  bool failed = false;
  String prefixNomor = "";
  PulsaModel selectedDenom;
  TextEditingController nomorHp = TextEditingController();
  String packageName = '';
  List<String> suggestNumbers = [];
  bool loadingSuggest = false;

  @override
  void initState() {
    super.initState();
    DebugHelper.debugPrint('=== PulsaController initState() START ===');
    DebugHelper.debugPrint('Menu Name: ${widget.menuModel.name}');
    DebugHelper.debugPrint('Menu Category ID: ${widget.menuModel.category_id}');
    
    DebugHelper.debugPrint('Calling _getPackageName()...');
    _getPackageName().then((_) {
      DebugHelper.debugPrint('✅ _getPackageName() completed, now calling getSuggestNumbers()...');
      getSuggestNumbers();
    });
    
    DebugHelper.debugPrint('getSuggestNumbers() scheduled (after _getPackageName)');
    DebugHelper.debugPrint('=== PulsaController initState() END ===');
  }

  Future<void> _getPackageName() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      packageName = info.packageName;
    });
  }

  Future<void> getSuggestNumbers() async {
    DebugHelper.debugPrint('=== PulsaController getSuggestNumbers() START ===');
    DebugHelper.debugPrint('Package Name: $packageName');
    DebugHelper.debugPrint('Menu Name: ${widget.menuModel.name}');
    DebugHelper.debugPrint('Menu Category ID: ${widget.menuModel.category_id}');
    
    // FITUR SUGGEST HISTORY NOMOR PEMBELI - EKSKLUSIF UNTUK APLIKASI SEEPAYS DAN PAYUNIOVO
    if (packageName != 'com.seepaysbiller.app' && packageName != 'mobile.payuni.id' && packageName != 'co.payuni.id') {
      DebugHelper.debugPrint('❌ Package name tidak didukung: $packageName');
      setState(() {
        suggestNumbers = [];
      });
      return;
    }
    
    DebugHelper.debugPrint('✅ Package name didukung: $packageName');

    try {
      setState(() {
        loadingSuggest = true;
      });

      
      String apiEndpoint;
      
   
      String kategoriId = widget.menuModel.category_id;
      if (kategoriId == null || kategoriId.isEmpty) {
        
        if (packageName == 'mobile.payuni.id' || packageName == 'co.payuni.id') {
          
          List<String> payuniovoPulsaCategoryIds = [
            '5eb704e9c78b532302ab4118',  
            '5eb704e8c78b53b66cab40d9',  
            '5eb704e8c78b534178ab3f52',  
            '5eb704e8c78b536e52ab4029',  
            '607aef122e7b75785eeaa909',  
            '5eb704e8c78b5348f8ab3f86',  
            '5eb704e9c78b535885ab413e',  
          ];
          kategoriId = payuniovoPulsaCategoryIds.join(',');  
        } else {
          
          List<String> seepaysPulsaCategoryIds = [
            '685b71969a3036284f0d8fec',  
            '685b71969a3036284f0d8feb',  
            '685b71969a3036284f0d8fef',  
            '685b71969a3036284f0d8ff1',   
            '685b71969a3036284f0d8ff0', 
            '685b71969a3036284f0d8fee', 
            '685b71969a3036284f0d8fed',  
          ];
          kategoriId = seepaysPulsaCategoryIds.join(','); // Gabungkan semua category ID
        }
        DebugHelper.debugPrint('⚠️ Category ID kosong, menggunakan fallback: $kategoriId');
      }
      
      if (packageName == 'mobile.payuni.id' || packageName == 'co.payuni.id') {
        
        List<String> payuniovoCategoryIds = [
          '5eb704e9c78b532302ab4118',  
          '5eb704e8c78b53b66cab40d9',  
          '5eb704e8c78b534178ab3f52',  
          '5eb704e8c78b536e52ab4029',  
          '607aef122e7b75785eeaa909',  
          '5eb704e8c78b5348f8ab3f86',  
          '5eb704e9c78b535885ab413e',  
        ];
        
        
        List<dynamic> allTransactions = [];
        
        // Scan setiap category id
        for (String categoryId in payuniovoCategoryIds) {
          String singleApiEndpoint = 'https://payuni-app.findig.id/api/v1/trx/lastTransaction?kategori_id=$categoryId&limit=1000&skip=0';
          DebugHelper.debugPrint('🌐 Scanning Payuniovo category ID: $categoryId');
          
          try {
            http.Response response = await http.get(
              Uri.parse(singleApiEndpoint),
              headers: {'Authorization': bloc.token.valueWrapper?.value},
            );
            
            if (response.statusCode == 200) {
              DebugHelper.debugPrint('✅ Success for Payuniovo category ID: $categoryId');
              dynamic responseData = json.decode(response.body);
              List<dynamic> datas = [];
              
              if (responseData is List) {
                datas = responseData;
              } else if (responseData is Map<String, dynamic>) {
                datas = responseData['data'] ?? [];
              }
              
              allTransactions.addAll(datas);
              DebugHelper.debugPrint('📊 Found ${datas.length} transactions for Payuniovo category: $categoryId');
            } else {
              DebugHelper.debugPrint('❌ Failed for Payuniovo category ID: $categoryId - Status: ${response.statusCode}');
            }
          } catch (error) {
            DebugHelper.debugPrint('❌ Error for Payuniovo category ID: $categoryId - $error');
          }
        }
        
        DebugHelper.debugPrint('📊 Total Payuniovo transactions found: ${allTransactions.length}');
        
        if (allTransactions.isNotEmpty) {
          DebugHelper.debugPrint('✅ Payuniovo: Processing ${allTransactions.length} combined transactions');
          
          // Sort berdasarkan tanggal terbaru
          allTransactions.sort((a, b) {
            final String ac = (a['tanggal'] ?? '');
            final String bc = (b['tanggal'] ?? '');
            DateTime ad, bd;
            try { ad = DateTime.parse(ac); } catch (_) { ad = DateTime.fromMillisecondsSinceEpoch(0); }
            try { bd = DateTime.parse(bc); } catch (_) { bd = DateTime.fromMillisecondsSinceEpoch(0); }
            return bd.compareTo(ad);
          });
          
          // Filter dan ambil nomor tujuan yang unik
          final Set<String> uniqueTargets = <String>{};
          for (final dynamic item in allTransactions) {
            final String tujuanItem = (item['tujuan'] ?? '').toString().trim();
            if (tujuanItem.isNotEmpty && tujuanItem.length >= 8 && tujuanItem.length <= 20) {
              uniqueTargets.add(tujuanItem);
              // Hapus batasan 10, ambil semua nomor yang valid
            }
          }
          
          setState(() { 
            suggestNumbers = uniqueTargets.toList(); 
          });
          DebugHelper.debugPrint('🎯 Final Payuniovo suggest numbers: $suggestNumbers');
        } else {
          setState(() { 
            suggestNumbers = ['Belum pernah transaksi di produk ini']; 
          });
        }
        
        setState(() { loadingSuggest = false; });
        DebugHelper.debugPrint('=== PulsaController getSuggestNumbers() END ===');
        return;
        
      } else if (packageName == 'com.seepaysbiller.app') {
        // API khusus Seepays - menggunakan lastTransaction
        apiEndpoint = 'https://app.payuni.co.id/api/v1/trx/lastTransaction?kategori_id=$kategoriId&limit=1000&skip=0';
        DebugHelper.debugPrint('🌐 Menggunakan API Seepays dengan kategori: $apiEndpoint');
      } else {
        // API default untuk produk lain
        if (kategoriId.isNotEmpty) {
          apiEndpoint = '$apiUrl/trx/list?page=0&limit=50&kategori_id=$kategoriId';
          DebugHelper.debugPrint('🌐 Menggunakan API Default dengan kategori: $apiEndpoint');
        } else {
          apiEndpoint = '$apiUrl/trx/list?page=0&limit=50';
          DebugHelper.debugPrint('🌐 Menggunakan API Default tanpa kategori: $apiEndpoint');
        }
      }

      DebugHelper.debugPrint('📡 Calling API...');
      final response = await http.get(
        Uri.parse(apiEndpoint),
        headers: {
          'Authorization': bloc.token.valueWrapper?.value,
        },
      );
      
      DebugHelper.debugPrint('📡 Response Status: ${response.statusCode}');
      DebugHelper.debugPrint('📡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> datas;
        String sortKey;
        
        if (packageName == 'mobile.payuni.id' || packageName == 'co.payuni.id' || packageName == 'com.seepaysbiller.app') {
          // Response Payuniovo dan Seepays langsung berupa array
          datas = json.decode(response.body) as List<dynamic>;
          sortKey = 'tanggal';
        } else {
          // Response produk lain nested dalam data
          final Map<String, dynamic> jsonBody = json.decode(response.body);
          datas = (jsonBody['data'] ?? []) as List<dynamic>;
          sortKey = 'created_at';
        }

        // Sort by key yang sesuai
        datas.sort((a, b) {
          final String ac = (a[sortKey] ?? '');
          final String bc = (b[sortKey] ?? '');
          DateTime ad, bd;
          try { ad = DateTime.parse(ac); } catch (_) { ad = DateTime.fromMillisecondsSinceEpoch(0); }
          try { bd = DateTime.parse(bc); } catch (_) { bd = DateTime.fromMillisecondsSinceEpoch(0); }
          return bd.compareTo(ad);
        });

        final Set<String> uniqueTargets = <String>{};

        if (packageName == 'mobile.payuni.id' || packageName == 'co.payuni.id' || packageName == 'com.seepaysbiller.app') {
          // Payuniovo dan Seepays: terima semua format (PLN ID, HP, dll)
          DebugHelper.debugPrint('🔍 Processing Payuniovo/Seepays data...');
          for (final dynamic item in datas) {
            final String tujuanItem = (item['tujuan'] ?? '').toString().trim();
            DebugHelper.debugPrint('🔍 Item tujuan: "$tujuanItem"');
            if (tujuanItem.isEmpty) {
              DebugHelper.debugPrint('❌ Tujuan kosong, skip');
              continue;
            }

            if (tujuanItem.length >= 8 && tujuanItem.length <= 20) {
              DebugHelper.debugPrint('✅ Tujuan valid, tambahkan: $tujuanItem');
              uniqueTargets.add(tujuanItem);
              // Hapus batasan 5, ambil semua nomor yang valid
            } else {
              DebugHelper.debugPrint('❌ Tujuan tidak valid (length: ${tujuanItem.length}): $tujuanItem');
            }
          }
          DebugHelper.debugPrint('🔍 Total unique targets Payuniovo/Seepays: ${uniqueTargets.length}');
        } else {
          // Allowed product codes from current denom list
          final Set<String> allowedCodes = listDenom
              .map((e) => (e.kodeProduk ?? '').toString())
              .where((e) => e.isNotEmpty)
              .toSet();

          for (final dynamic item in datas) {
            final Map<String, dynamic> prod = (item['produk_id'] ?? {}) as Map<String, dynamic>;
            final String code = (prod['kode_produk'] ?? '').toString();
            final String name = (prod['nama'] ?? '').toString();
            final String tujuanItem = (item['tujuan'] ?? '').toString().trim();
            if (tujuanItem.isEmpty) continue;

            bool matchesMenu = true;
            if (allowedCodes.isNotEmpty) {
              matchesMenu = allowedCodes.contains(code);
            } else {
              // Heuristic: match by menu name keywords
              final String menuName = (widget.menuModel.name ?? '').toLowerCase();
              final String n = name.toLowerCase();
              final String c = code.toLowerCase();
              if (menuName.contains('dana')) {
                matchesMenu = n.contains('dana') || c.contains('dana');
              } else if (menuName.contains('ovo')) {
                matchesMenu = n.contains('ovo') || c.contains('ovo');
              } else if (menuName.contains('gopay') || menuName.contains('gojek')) {
                matchesMenu = n.contains('gopay') || n.contains('gojek') || c.contains('gopay');
              } else if (menuName.contains('shopee')) {
                matchesMenu = n.contains('shopee') || c.contains('shopee');
              } else if (menuName.contains('mobile legends') || menuName.contains('ml') || menuName.contains('mlbb')) {
                matchesMenu = n.contains('mobile') || n.contains('legends') || c.contains('ml');
              } else if (menuName.contains('free fire') || menuName.contains('ff')) {
                matchesMenu = n.contains('free') || n.contains('fire') || c.contains('ff');
              }
            }

            if (matchesMenu) {
              uniqueTargets.add(tujuanItem);
              // Hapus batasan 10, ambil semua nomor yang valid
            }
          }
        }

        DebugHelper.debugPrint('🎯 Final suggest numbers: ${uniqueTargets.toList()}');
        setState(() {
          suggestNumbers = uniqueTargets.toList();
        });
      } else {
        DebugHelper.debugPrint('❌ API response tidak berhasil: ${response.statusCode}');
        setState(() {
          suggestNumbers = [];
        });
      }
    } catch (error) {
      DebugHelper.debugPrint('❌ Error dalam getSuggestNumbers: $error');
      setState(() {
        suggestNumbers = [];
      });
    } finally {
      DebugHelper.debugPrint('🏁 Setting loadingSuggest = false');
      setState(() {
        loadingSuggest = false;
      });
    }
    DebugHelper.debugPrint('=== PulsaController getSuggestNumbers() END ===');
  }

  void selectSuggestNumber(String number) {
    DebugHelper.debugPrint('🎯 Suggest number diklik: $number');
    setState(() {
      nomorHp.text = number;
    });
    
    // Auto-load denom setelah nomor diisi
    if (number.length >= 4 && number.startsWith('08')) {
      DebugHelper.debugPrint('🚀 Auto-loading denom untuk nomor: $number');
      
      // Reset state
      setState(() {
        listDenom.clear();
        prefixNomor = number.substring(0, 4);
        loading = true;
      });
      
      // Load denom
      getDenom(number);
    } else {
      DebugHelper.debugPrint('⚠️ Nomor tidak valid untuk auto-load denom: $number');
    }
  }

  void getDenom(String nomor) async {
    setState(() {
      loading = true;
    });

    http.Response response = await http.get(
        Uri.parse('$apiUrl/product/pulsa?q=$nomor'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      List<PulsaModel> list = (json.decode(response.body)['data'] as List)
          .map((item) => PulsaModel.fromJson(item))
          .toList();
      listDenom = list;
    }

    setState(() {
      loading = false;
    });
  }

  void selectDenom(PulsaModel denom) {
    if (denom.note == 'gangguan') {
      ScaffoldMessenger.of(context).showSnackBar(
        Alert(
          'Produk sedang mengalami gangguan',
          isError: true,
        ),
      );
      return;
    }
    if (denom != null) {
      setState(() {
        selectedDenom = denom;
      });
    }
  }
}
