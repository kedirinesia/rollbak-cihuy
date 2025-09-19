// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/models/prepaid-denom.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/Products/seepays/layout/detail-denom.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Bloc.dart' show bloc;
import 'package:mobile/bloc/Api.dart' show apiUrl;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mobile/utils/debug_helper.dart';

abstract class SeepaysDetailDenomController extends State<SeepaysDetailDenom>
    with TickerProviderStateMixin {
  List<PrepaidDenomModel> listDenom = [];
  String coverIcon = '';
  bool loading = true;
  bool failed = false;
  PrepaidDenomModel selectedDenom;
  TextEditingController tujuan = TextEditingController();
  TextEditingController nominal = TextEditingController();
  String packageName = '';
  List<String> suggestNumbers = [];
  bool loadingSuggest = false;
  final bool useApiSuggest = true; // set true untuk gunakan API

  @override
  void initState() {
    super.initState();
    _getPackageName().then((_) {
      getData();
      getSuggestNumbers();
    });
    analitycs.pageView('/menu/transaksi/' + widget.menu.category_id, {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Buka Menu ' + widget.menu.name
    });
  }

  Future<void> _getPackageName() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      packageName = info.packageName;
    });
  }

  getData() async {
    http.Response response = await http.get(
        Uri.parse('$apiUrl/product/${widget.menu.category_id}'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      List<PrepaidDenomModel> lm = (jsonDecode(response.body)['data'] as List)
          .map((m) => PrepaidDenomModel.fromJson(m))
          .toList();

      // SET CATEGORY COVER ICON
      coverIcon = json.decode(response.body)['url_image'] ?? '';

      setState(() {
        listDenom = lm;
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
        listDenom = [];
      });
    }
  }

  onTapDenom(denom) {
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

  Future<void> getSuggestNumbers() async {
    DebugHelper.debugPrint('=== Seepays Detail Denom getSuggestNumbers() START ===');
    DebugHelper.debugPrint('🔍 Package Name: $packageName');
    DebugHelper.debugPrint('🔍 Menu Name: ${widget.menu.name}');
    DebugHelper.debugPrint('🔍 Menu Kode Produk: ${widget.menu.kodeProduk}');
    DebugHelper.debugPrint('🔍 Category ID: ${widget.menu.category_id}');
    DebugHelper.debugPrint('🔍 Use API Suggest: $useApiSuggest');
    DebugHelper.debugPrint('🔍 API URL: $apiUrl');
    
    // FITUR SUGGEST HISTORY NOMOR PEMBELI - EKSKLUSIF UNTUK APLIKASI SEEPAYS
    if (packageName != 'com.seepaysbiller.app') {
      DebugHelper.debugPrint('❌ Not Seepays, skipping suggest numbers');
      setState(() {
        suggestNumbers = [];
      });
      return;
    }

    DebugHelper.debugPrint('✅ Seepays detected, proceeding with suggest numbers');

    if (!useApiSuggest) {
      DebugHelper.debugPrint('📋 Using hardcoded suggestions');
      setState(() {
        suggestNumbers = _hardcodedSuggestionsForMenu(widget.menu.name);
      });
      return;
    }

    DebugHelper.debugPrint('🌐 Using API suggestions');

    try {
      setState(() { loadingSuggest = true; });

      // Gunakan kategori ID untuk pulsa jika tersedia
      String finalCategoryId = widget.menu.category_id ?? '';
      
      DebugHelper.debugPrint('🔍 Final Category ID before check: "$finalCategoryId"');
      
      if (finalCategoryId.isEmpty || finalCategoryId == 'null') {
        DebugHelper.debugPrint('⚠️ Category ID kosong atau null, menampilkan pesan "Belum pernah transaksi"');
        setState(() { 
          suggestNumbers = ['Belum pernah transaksi di produk ini']; 
          loadingSuggest = false;
        });
        return;
      }
      
      String apiEndpoint = '$apiUrl/trx/lastTransaction?kategori_id=$finalCategoryId&limit=10&skip=0';
      
      DebugHelper.debugPrint('🌐 Seepays API Endpoint: $apiEndpoint');
      DebugHelper.debugPrint('🔍 Category ID: ${widget.menu.category_id}');
      
      final response = await http.get(
        Uri.parse(apiEndpoint),
        headers: { 'Authorization': bloc.token.valueWrapper?.value },
      );

      DebugHelper.debugPrint('📡 Response Status: ${response.statusCode}');
      DebugHelper.debugPrint('📡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Response lastTransaction langsung berupa array
        final List<dynamic> datas = json.decode(response.body) as List<dynamic>;
        DebugHelper.debugPrint('📊 Found ${datas.length} transactions in response');

        if (datas.isEmpty) {
          DebugHelper.debugPrint('📭 No transactions found for category: ${widget.menu.category_id}');
          setState(() { 
            suggestNumbers = ['Belum pernah transaksi di produk ini']; 
          });
          return;
        }

        // sort terbaru dulu berdasarkan tanggal
        datas.sort((a, b) {
          final String ac = (a['tanggal'] ?? '');
          final String bc = (b['tanggal'] ?? '');
          DateTime ad, bd;
          try { ad = DateTime.parse(ac); } catch (_) { ad = DateTime.fromMillisecondsSinceEpoch(0); }
          try { bd = DateTime.parse(bc); } catch (_) { bd = DateTime.fromMillisecondsSinceEpoch(0); }
          return bd.compareTo(ad);
        });

        final Set<String> uniqueTargets = <String>{};
        for (final dynamic item in datas) {
          final String tujuanItem = (item['tujuan'] ?? '').toString().trim();
          DebugHelper.debugPrint('🔍 Processing item: $tujuanItem');
          if (tujuanItem.isEmpty) continue;

          // Terima semua format yang valid (HP, PLN ID, dll)
          if (tujuanItem.length >= 8 && tujuanItem.length <= 20) {
            uniqueTargets.add(tujuanItem);
            DebugHelper.debugPrint('✅ Added to suggestions: $tujuanItem');
            // Hapus batasan 10, ambil semua nomor yang valid
          } else {
            DebugHelper.debugPrint('❌ Skipped (invalid length): $tujuanItem');
          }
        }

        setState(() { 
          suggestNumbers = uniqueTargets.toList(); 
        });
        DebugHelper.debugPrint('✅ Final suggest numbers: $suggestNumbers');
      } else {
        DebugHelper.debugPrint('❌ API failed with status: ${response.statusCode}');
        setState(() { 
          suggestNumbers = ['Belum pernah transaksi di produk ini']; 
        });
      }
    } catch (error) {
      DebugHelper.debugPrint('❌ Error dalam getSuggestNumbers: $error');
      setState(() { 
        suggestNumbers = ['Belum pernah transaksi di produk ini']; 
      });
    } finally {
      setState(() { loadingSuggest = false; });
    }
    
    DebugHelper.debugPrint('=== Seepays Detail Denom getSuggestNumbers() END ===');
  }

  List<String> _hardcodedSuggestionsForMenu(String menuName) {
    DebugHelper.debugPrint('🔍 _hardcodedSuggestionsForMenu called for: $menuName');
    final String name = (menuName ?? '').toLowerCase();
    DebugHelper.debugPrint('🔍 Normalized menu name: $name');
    
    if (name.contains('dana')) {
      DebugHelper.debugPrint('✅ Returning Dana suggestions');
      return ['085852076162', '081234567890', '088123456789', '087812345678'];
    } else if (name.contains('ovo')) {
      DebugHelper.debugPrint('✅ Returning OVO suggestions');
      return ['081234567890', '081298765432', '082111223344'];
    } else if (name.contains('gopay') || name.contains('gojek')) {
      DebugHelper.debugPrint('✅ Returning Gopay suggestions');
      return ['085700112233', '085700223344', '085700334455'];
    } else if (name.contains('shopee')) {
      DebugHelper.debugPrint('✅ Returning Shopee suggestions');
      return ['081390001122', '081390002233', '081390003344'];
    } else if (name.contains('mobile legends') || name.contains('ml') || name.contains('mlbb')) {
      DebugHelper.debugPrint('✅ Returning MLBB suggestions');
      return ['100012345678', '200012345678', '300012345678'];
    } else if (name.contains('free fire') || name.contains('ff')) {
      DebugHelper.debugPrint('✅ Returning Free Fire suggestions');
      return ['1212', '1213', '2'];
    } else if (name.contains('pubg')) {
      DebugHelper.debugPrint('✅ Returning PUBG suggestions');
      return ['555001122', '555002233', '555003344'];
    } else if (name.contains('pln')) {
      DebugHelper.debugPrint('✅ Returning PLN suggestions');
      return ['123456789', '987654321'];
    }
    DebugHelper.debugPrint('⚠️ No specific suggestions found, returning default');
    return ['081234567890', '082112223333', '089512345678'];
  }
} 