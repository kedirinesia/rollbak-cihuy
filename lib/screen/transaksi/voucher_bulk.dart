
import 'dart:convert';

import 'dart:async';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/menu.dart';
import 'package:mobile/models/prepaid-denom.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/utils/debug_helper.dart';
import 'package:mobile/screen/transaksi/inquiry_prepaid.dart';
import 'package:mobile/screen/transaksi/list_voucher_denom.dart';
import 'package:mobile/screen/transaksi/verifikasi_pin.dart';
import 'package:http/http.dart' as http;

class VoucherBulkPage extends StatefulWidget {
  final MenuModel menu;
  const VoucherBulkPage(this.menu, {Key? key}) : super(key: key);

  @override
  State<VoucherBulkPage> createState() => _VoucherBulkPageState();
}

class _VoucherBulkPageState extends State<VoucherBulkPage> {
  bool _loading = false;
  TextEditingController _voucherCode = TextEditingController();
  TextEditingController _voucherStartCode = TextEditingController();
  TextEditingController _voucherEndCode = TextEditingController();
  List<Map<String, dynamic>> _masterVouchers = [];
  List<Map<String, dynamic>> _vouchers = [];
  late PrepaidDenomModel _denom;
  int totalHarga = 0;
  bool _isPromo = false;
  int _filteredStatus = 0;
  String _voucherLabel = 'Semua Voucher :';

  @override
  void dispose() {
    DebugHelper.debugPrint('=== Disposing VoucherBulkPage ===');
    DebugHelper.debugPrint('Disposing text controllers');
    _voucherCode.dispose();
    _voucherStartCode.dispose();
    _voucherEndCode.dispose();
    super.dispose();
    DebugHelper.debugPrint('VoucherBulkPage disposed');
  }

  void _calculateTotalHarga() {
    DebugHelper.debugPrint('=== Starting _calculateTotalHarga ===');
    DebugHelper.debugPrint('Denom harga_jual: ${_denom.harga_jual ?? "null"}');
    DebugHelper.debugPrint('Vouchers length: ${_vouchers.length}');
    int selectedCount = _vouchers.where((v) => v['selected'] == true).length;
    totalHarga = _denom.harga_jual * selectedCount;
    DebugHelper.debugPrint('"Total Harga calculated: $totalHarga"');
  }

  void _generateVoucher() {
    DebugHelper.debugPrint('=== Starting _generateVoucher ===');
    DebugHelper.debugPrint('Loading state: $_loading');
    
    if (_loading) {
      DebugHelper.debugPrint('Currently loading, returning');
      return;
    }

    try {
      String startCodeText = _voucherStartCode.text.trim();
      String endCodeText = _voucherEndCode.text.trim();
      
      DebugHelper.debugPrint('Start code text: "$startCodeText"');
      DebugHelper.debugPrint('End code text: "$endCodeText"');

      if (startCodeText.isEmpty || endCodeText.isEmpty) {
        DebugHelper.debugPrint('Start or end code is empty, returning');
        return;
      }

      int startCode = int.parse(startCodeText);
      int endCode = int.parse(endCodeText);
      
      DebugHelper.debugPrint('Start code: $startCode');
      DebugHelper.debugPrint('End code: $endCode');

      if (startCode == endCode) {
        DebugHelper.debugPrint('Start and end codes are the same, returning');
        return;
      }
      
      DebugHelper.debugPrint('Clearing master vouchers');
      _masterVouchers.clear();

      int codeLength = startCodeText.length;
      DebugHelper.debugPrint('Code length: $codeLength');

      if (startCode <= endCode) {
        DebugHelper.debugPrint('Generating vouchers in ascending order');
        for (int i = startCode; i <= endCode; i++) {
          String code = i.toString().padLeft(codeLength, '0');
          _masterVouchers.add({
            'code': code,
            'selected': false,
            'status': 1,
          });
        }
      } else {
        DebugHelper.debugPrint('Generating vouchers in descending order');
        for (int i = startCode; i >= endCode; i--) {
          String code = i.toString().padLeft(codeLength, '0');
          _masterVouchers.add({
            'code': code,
            'selected': false,
            'status': 1,
          });
        }
      }

      DebugHelper.debugPrint('Total vouchers generated: ${_masterVouchers.length}');
      _vouchers = List<Map<String, dynamic>>.from(_masterVouchers);
      _calculateTotalHarga();

      DebugHelper.debugPrint('Setting state');
      setState(() {});
    } catch (err) {
      DebugHelper.debugPrint('Error in _generateVoucher: $err');
      DebugHelper.debugPrint('Error type: ${err.runtimeType}');
    }
  }

  Future<void> _scanBarcode(String type) async {
    DebugHelper.debugPrint('=== Starting _scanBarcode ===');
    DebugHelper.debugPrint('Scan type: $type');
    DebugHelper.debugPrint('Loading state: $_loading');
    
    if (_loading) {
      DebugHelper.debugPrint('Currently loading, returning');
      return;
    }

    DebugHelper.debugPrint('Starting barcode scanner...');
    ScanResult result = await BarcodeScanner.scan();
    DebugHelper.debugPrint('Scan result received');
    DebugHelper.debugPrint('Raw content: "${result.rawContent}"');
    DebugHelper.debugPrint('Raw content length: ${result.rawContent.length}');
    
    if (result.rawContent.isEmpty) {
      DebugHelper.debugPrint('Raw content is empty, returning');
      return;
    }
    
    DebugHelper.debugPrint('Setting scanned content to text field');
    setState(() {
      if (type == 'start') {
        _voucherStartCode.text = result.rawContent;
        DebugHelper.debugPrint('Set start code to: ${result.rawContent}');
      } else if (type == 'end') {
        _voucherEndCode.text = result.rawContent;
        DebugHelper.debugPrint('Set end code to: ${result.rawContent}');
      } else if (type == 'single') {
        _voucherCode.text = result.rawContent;
        DebugHelper.debugPrint('Set single code to: ${result.rawContent}');
      }
    });
  }

  Future<void> _selectDenom() async {
    DebugHelper.debugPrint('=== Starting _selectDenom ===');
    DebugHelper.debugPrint('Loading state: $_loading');
    
    if (_loading) {
      DebugHelper.debugPrint('Currently loading, returning');
      return;
    }

    DebugHelper.debugPrint('Navigating to ListVoucherDenomPage');
    PrepaidDenomModel result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListVoucherDenomPage(widget.menu),
      ),
    );

    DebugHelper.debugPrint('Result from denom selection: ${result != null ? "Selected" : "Cancelled"}');
    if (result == null) {
      DebugHelper.debugPrint('No denom selected, returning');
      return;
    }

    DebugHelper.debugPrint('Setting denom data');
    DebugHelper.debugPrint('Denom kode_produk: ${result.kode_produk}');
    DebugHelper.debugPrint('Denom nama: ${result.nama}');
    DebugHelper.debugPrint('Denom harga_jual: ${result.harga_jual}');
    DebugHelper.debugPrint('Denom harga_promo: ${result.harga_promo}');
    
    setState(() {
      _denom = result;
      _isPromo = result.harga_promo > 0 &&
          result.harga_jual > result.harga_promo;
    });
    
    DebugHelper.debugPrint('Is promo: $_isPromo');
  }

  Future<void> _processVoucher() async {
    DebugHelper.debugPrint('=== Starting _processVoucher ===');
    DebugHelper.debugPrint('Menu jenis: ${widget.menu.jenis}');
    DebugHelper.debugPrint('Denom is null: ${_denom == null}');
    DebugHelper.debugPrint('Vouchers length: ${_vouchers.length}');
    
    if (widget.menu.jenis == 5) {
      DebugHelper.debugPrint('Processing single voucher (jenis 5)');
      if (_denom == null) {
        DebugHelper.debugPrint('Denom is null, returning');
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              InquiryPrepaid(_denom.kode_produk, _voucherCode.text.trim()),
        ),
      );
      return;
    } else if (widget.menu.jenis == 6) {
      DebugHelper.debugPrint('Processing bulk voucher (jenis 6)');
      if (_vouchers.length == 0) {
        DebugHelper.debugPrint('Denom is null or vouchers empty, returning');
        return;
      }

      DebugHelper.debugPrint('Checking balance...');
      bool isBalanceEnough = await _checkBalance();
      DebugHelper.debugPrint('Balance check result: $isBalanceEnough');
      if (!isBalanceEnough) {
        DebugHelper.debugPrint('Insufficient balance, returning');
        return;
      }

      DebugHelper.debugPrint('Showing confirmation dialog...');
      bool status = await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text(
            'Setelah memasukkan kode PIN, sistem akan memotong saldo dan memproses transaksi anda tanpa melalui proses inquiry. Apakah anda yakin untuk melanjutkan transaksi ?',
            textAlign: TextAlign.justify,
          ),
          actions: [
            TextButton(
              child: Text(
                'LANJUT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
            TextButton(
              child: Text(
                'BATAL',
                style: TextStyle(
                  color: Colors.red.shade600,
                ),
              ),
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
          ],
        ),
      );
      DebugHelper.debugPrint('Dialog result: $status');
      if (!status) return;

      try {
        if (_loading) {
          DebugHelper.debugPrint('Already loading, returning');
          return;
        }

        DebugHelper.debugPrint('Setting loading to true');
        setState(() {
          _loading = true;
        });

        DebugHelper.debugPrint('Navigating to PIN verification...');
        String pin = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VerifikasiPin(),
          ),
        );
        DebugHelper.debugPrint('PIN verification result: ${pin != null ? "PIN received" : "PIN cancelled"}');
        if (pin == null) return;

        DebugHelper.debugPrint('Sending device token...');
        sendDeviceToken();

        DebugHelper.debugPrint('Starting voucher processing loop...');
        // Hanya proses voucher yang tercentang dan belum sukses
        final toProcess = _vouchers
            .where((v) => v['selected'] == true && v['status'] != 2)
            .toList();
        DebugHelper.debugPrint('Total vouchers to process: ${toProcess.length}');

        for (var voucher in toProcess) {
          int i = _vouchers.indexWhere((el) => el['code'] == voucher['code']);
          DebugHelper.debugPrint('Processing voucher $i: ${voucher['code']}');
          DebugHelper.debugPrint('Voucher selected: ${voucher['selected']}');
          DebugHelper.debugPrint('Voucher status: ${voucher['status']}');

          DebugHelper.debugPrint('Calling _purchaseVoucher for index $i');
          await _purchaseVoucher(i, pin);
        }

        DebugHelper.debugPrint('All vouchers processed, showing success message');
        ScaffoldMessenger.of(context).showSnackBar(
          Alert(
            'Transaksi sedang diproses, anda dapat memantau status transaksi pada halaman riwayat transaksi',
          ),
        );

        setState(() {
          _loading = false;
        });
      } catch (err) {
        DebugHelper.debugPrint('Error in _processVoucher: $err');
        DebugHelper.debugPrint('Error type: ${err.runtimeType}');
      } finally {
        DebugHelper.debugPrint('Setting loading to false in finally block');
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _purchaseVoucher(int index, String pin) async {
    DebugHelper.debugPrint('=== Starting voucher purchase for index $index ===');
          DebugHelper.debugPrint('API URL: $apiUrl/trx/prepaid/purchase');
    DebugHelper.debugPrint('Token available: ${bloc.token.valueWrapper?.value != null}');
    DebugHelper.debugPrint('Token length: ${bloc.token.valueWrapper?.value?.length ?? 0}');
    DebugHelper.debugPrint('Denom kode_produk: ${_denom.kode_produk}');
    DebugHelper.debugPrint('Voucher code: ${_vouchers[index]['code']}');
    
    try {
      var dataToSend = {
        'kode_produk': _denom.kode_produk,
        'tujuan': _vouchers[index]['code'],
        'counter': 1,
        'pin': pin,
      };
      
      DebugHelper.debugPrint('Request data: ${json.encode(dataToSend)}');
      DebugHelper.debugPrint('Headers: ${{
        'Content-Type': 'application/json',
        'Authorization': bloc.token.valueWrapper?.value ?? '',
      }}');

      DebugHelper.debugPrint('Making HTTP request...');
      http.Response response = await http
          .post(
            Uri.parse('$apiUrl/trx/prepaid/purchase'),
            headers: {  
              'Content-Type': 'application/json',
              'Authorization': bloc.token.valueWrapper?.value ?? '',
            },
            body: json.encode(dataToSend),
          )
          .timeout(Duration(minutes: 5));
      
      DebugHelper.debugPrint('Response received');
      DebugHelper.debugPrint('Status code: ${response.statusCode}');
      DebugHelper.debugPrint('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        _vouchers[index]['status'] = 2;
        _vouchers[index]['trx_id'] = responseData['data']['trx_id'];
        _vouchers[index]['harga'] = responseData['data']['harga'];
        DebugHelper.debugPrint('Voucher purchase successful - TRX ID: ${responseData['data']['trx_id']}');
      } else {
        _vouchers[index]['status'] = 3;
        DebugHelper.debugPrint('Voucher purchase failed with status: ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      _vouchers[index]['status'] = 3;
      DebugHelper.debugPrint('TimeoutException caught: $e');
      DebugHelper.debugPrint('Request timed out after 5 minutes');
    } catch (err) {
      _vouchers[index]['status'] = 3;
      DebugHelper.debugPrint('Unexpected error caught: $err');
      DebugHelper.debugPrint('Error type: ${err.runtimeType}');
      DebugHelper.debugPrint('Error toString: ${err.toString()}');
      
      // Check if it's an SSL/Handshake error
      if (err.toString().contains('HandshakeException') || 
          err.toString().contains('handshake') ||
          err.toString().contains('SSL')) {
        DebugHelper.debugPrint('This appears to be an SSL/Handshake error');
        DebugHelper.debugPrint('Full error details: $err');
      }
      
      // Check if it's a network connectivity issue
      if (err.toString().contains('SocketException') ||
          err.toString().contains('Connection') ||
          err.toString().contains('Network')) {
        DebugHelper.debugPrint('This appears to be a network connectivity issue');
        DebugHelper.debugPrint('Full error details: $err');
      }
    } finally {
      DebugHelper.debugPrint('Setting state and completing voucher purchase for index $index');
      setState(() {});
    }
  }

  Future<bool> _checkBalance() async {
    DebugHelper.debugPrint('=== Starting _checkBalance ===');
    DebugHelper.debugPrint('Denom harga_jual: ${_denom.harga_jual}');
    DebugHelper.debugPrint('Vouchers length: ${_vouchers.length}');
    
    double totalAmount = _denom.harga_jual.toDouble() * _vouchers.length;
    DebugHelper.debugPrint('Total amount needed: $totalAmount');
    DebugHelper.debugPrint('User saldo: ${bloc.user.valueWrapper?.value.saldo}');
    DebugHelper.debugPrint('Is balance sufficient: ${bloc.user.valueWrapper!.value.saldo >= totalAmount}');

    if (bloc.user.valueWrapper!.value.saldo < totalAmount) {
      DebugHelper.debugPrint('Insufficient balance, showing dialog');
      showDialog(
          context: context,
          builder: (BuildContext ctx) {
            Future.delayed(Duration(seconds: 2), () {
              Navigator.of(ctx).pop(); // Menutup dialog/alert
            });
            return AlertDialog(
              title: Text('Error'),
              content: Text('Saldo tidak cukup.'),
            );
          });
      return false;
    } else {
      DebugHelper.debugPrint('Balance is sufficient');
      return true;
    }
  }

  void _updateFilter(int status) {
    DebugHelper.debugPrint('=== Starting _updateFilter ===');
    DebugHelper.debugPrint('Filter status: $status');
    DebugHelper.debugPrint('Loading state: $_loading');
    
    if (_loading) {
      DebugHelper.debugPrint('Currently loading, showing toast and returning');
      showToast(context,
          'Voucher sedang diproses, harap tunggu hingga voucher selesai diproses');
      return;
    }

    DebugHelper.debugPrint('Master vouchers count: ${_masterVouchers.length}');
    
    if (status == 0) {
      DebugHelper.debugPrint('Showing all vouchers');
      setState(() {
        _voucherLabel = 'Semua Voucher :';
        // gunakan salinan agar perubahan state lokal tidak hilang/saling menimpa
        _vouchers = List<Map<String, dynamic>>.from(_masterVouchers);
      });
    } else if (status == 1) {
      DebugHelper.debugPrint('Showing unprocessed vouchers');
      var filtered = _masterVouchers.where((el) => el['status'] == 1).toList();
      DebugHelper.debugPrint('Unprocessed vouchers count: ${filtered.length}');
      setState(() {
        _voucherLabel = 'Voucher Belum Diproses :';
        _vouchers = filtered;
      });
    } else if (status == 2) {
      DebugHelper.debugPrint('Showing successful vouchers');
      var filtered = _masterVouchers.where((el) => el['status'] == 2).toList();
      DebugHelper.debugPrint('Successful vouchers count: ${filtered.length}');
      setState(() {
        _voucherLabel = 'Voucher Berhasil :';
        _vouchers = filtered;
      });
    } else if (status == 3) {
      DebugHelper.debugPrint('Showing failed vouchers');
      var filtered = _masterVouchers.where((el) => el['status'] == 3).toList();
      DebugHelper.debugPrint('Failed vouchers count: ${filtered.length}');
      setState(() {
        _voucherLabel = 'Voucher Gagal :';
        _vouchers = filtered;
      });
    }
    
    DebugHelper.debugPrint('Filtered vouchers count: ${_vouchers.length}');
  }

  Widget _content() {
    DebugHelper.debugPrint('=== Building _content ===');
    DebugHelper.debugPrint('Menu jenis: ${widget.menu.jenis}');
    
    if (widget.menu.jenis == 6) {
      DebugHelper.debugPrint('Building bulk voucher content');
      // VOUCHER MASSAL
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kode Voucher Awal',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 5),
          packageName == 'com.eralink.mobileapk'
              ? TextFormField(
                  controller: _voucherStartCode,
                  enabled: !_loading,
                  keyboardType: TextInputType.number,
                  cursorColor: Theme.of(context).primaryColor,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: packageName == 'com.lariz.mobile'
                            ? Theme.of(context).secondaryHeaderColor
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.qr_code_2_rounded),
                      color: packageName == 'com.lariz.mobile'
                          ? Theme.of(context).secondaryHeaderColor
                          : Theme.of(context).primaryColor,
                      onPressed: () => _scanBarcode('start'),
                    ),
                  ),
                )
              : TextFormField(
                  controller: _voucherStartCode,
                  enabled: !_loading,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: packageName == 'com.lariz.mobile'
                            ? Theme.of(context).secondaryHeaderColor
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.qr_code_2_rounded),
                      color: packageName == 'com.lariz.mobile'
                          ? Theme.of(context).secondaryHeaderColor
                          : Theme.of(context).primaryColor,
                      onPressed: () => _scanBarcode('start'),
                    ),
                  ),
                ),
          SizedBox(height: 15),
          Text(
            'Kode Voucher Akhir',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 5),
          packageName == 'com.eralink.mobileapk'
              ? TextFormField(
                  controller: _voucherEndCode,
                  enabled: !_loading,
                  keyboardType: TextInputType.number,
                  cursorColor: Theme.of(context).primaryColor,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: packageName == 'com.lariz.mobile'
                            ? Theme.of(context).secondaryHeaderColor
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.qr_code_2_rounded),
                      color: packageName == 'com.lariz.mobile'
                          ? Theme.of(context).secondaryHeaderColor
                          : Theme.of(context).primaryColor,
                      onPressed: () => _scanBarcode('end'),
                    ),
                  ),
                )
              : TextFormField(
                  controller: _voucherEndCode,
                  enabled: !_loading,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: packageName == 'com.lariz.mobile'
                            ? Theme.of(context).secondaryHeaderColor
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.qr_code_2_rounded),
                      color: packageName == 'com.lariz.mobile'
                          ? Theme.of(context).secondaryHeaderColor
                          : Theme.of(context).primaryColor,
                      onPressed: () => _scanBarcode('end'),
                    ),
                  ),
                ),
          SizedBox(height: 15),
          MaterialButton(
            minWidth: double.infinity,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            color: packageName == 'com.lariz.mobile'
                ? Theme.of(context).secondaryHeaderColor
                : Theme.of(context).primaryColor,
            colorBrightness: Brightness.dark,
            elevation: 0,
            child: Text('Generate Voucher'),
            onPressed: _generateVoucher,
          ),
          Divider(),
          Container(
            width: double.infinity,
            height: 40,
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                vertical: 5,
              ),
              children: [
                InkWell(
                  onTap: () => _updateFilter(0),
                  child: Container(
                    height: 15,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    child: Center(
                      child: Text(
                        'SEMUA STATUS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                InkWell(
                  onTap: () => _updateFilter(2),
                  child: Container(
                    height: 15,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      border: Border.all(
                        color: Colors.green.shade200,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    child: Center(
                      child: Text(
                        'BERHASIL',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                InkWell(
                  onTap: () => _updateFilter(3),
                  child: Container(
                    height: 15,
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      border: Border.all(
                        color: Colors.red.shade200,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    child: Center(
                      child: Text(
                        'GAGAL',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade800,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                InkWell(
                  onTap: () => _updateFilter(1),
                  child: Container(
                    height: 15,
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      border: Border.all(
                        color: Colors.amber.shade200,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    child: Center(
                      child: Text(
                        'BELUM DIPROSES',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                _voucherLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Spacer(),
              Builder(
                builder: (_) {
                  int selectedVoucher = 0;
                  int totalVoucher = _vouchers.length;

                  _vouchers.forEach((voucher) {
                    if (voucher['selected']) selectedVoucher++;
                  });

                  return Text(
                    '$selectedVoucher / $totalVoucher',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: _vouchers.length == 0
                ? Container(
                    child: Center(
                      child: Text(
                        'Tidak Ada Voucher'.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _vouchers.length,
                    itemBuilder: (_, i) {
                      Map<String, dynamic> voucher = _vouchers[i];
                      Color bgColor = Colors.transparent;

                      if (voucher['selected']) {
                        switch (voucher['status']) {
                          case 1:
                            bgColor = Colors.amber.shade100;
                            break;
                          case 2:
                            bgColor = Colors.green.shade100;
                            break;
                          case 3:
                            bgColor = Colors.red.shade100;
                            break;
                          default:
                            bgColor = Colors.transparent;
                        }
                      }

                      return Container(
                        padding: EdgeInsets.symmetric(vertical: 3),
                        decoration: BoxDecoration(
                          color: bgColor,
                          border: Border.symmetric(
                            horizontal: BorderSide(
                              color: Colors.grey.shade300,
                              width: .5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              fillColor: WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return packageName == 'com.lariz.mobile'
                                      ? Theme.of(context).secondaryHeaderColor
                                      : Theme.of(context).primaryColor;
                                }
                                return Colors.white; // unchecked: putih
                              }),
                              value: voucher['selected'] == true,
                              onChanged: (value) {
                                if (_loading) return;

                                setState(() {
                                  final bool isSelected = (value ?? false) == true;
                                  voucher['selected'] = isSelected;
                                  // Sinkronkan perubahan ke master list agar tidak balik tercentang saat filter/regenerate
                                  int masterIndex = _masterVouchers
                                      .indexWhere((el) => el['code'] == voucher['code']);
                                  if (masterIndex != -1) {
                                    _masterVouchers[masterIndex]['selected'] = isSelected;
                                  }
                                  _calculateTotalHarga();
                                });
                              },
                            ),
                            Text(voucher['code']),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    } else {
      // VOUCHER MANUAL
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kode Voucher',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 5),
          packageName == 'com.eralink.mobileapk'
              ? TextFormField(
                  controller: _voucherCode,
                  enabled: !_loading,
                  keyboardType: TextInputType.number,
                  cursorColor: Theme.of(context).primaryColor,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: packageName == 'com.lariz.mobile'
                            ? Theme.of(context).secondaryHeaderColor
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.qr_code_2_rounded),
                      color: packageName == 'com.lariz.mobile'
                          ? Theme.of(context).secondaryHeaderColor
                          : Theme.of(context).primaryColor,
                      onPressed: () => _scanBarcode('single'),
                    ),
                  ),
                )
              : TextFormField(
                  controller: _voucherCode,
                  enabled: !_loading,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: packageName == 'com.lariz.mobile'
                            ? Theme.of(context).secondaryHeaderColor
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.qr_code_2_rounded),
                      color: packageName == 'com.lariz.mobile'
                          ? Theme.of(context).secondaryHeaderColor
                          : Theme.of(context).primaryColor,
                      onPressed: () => _scanBarcode('single'),
                    ),
                  ),
                ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    DebugHelper.debugPrint('=== Building VoucherBulkPage ===');
    DebugHelper.debugPrint('Loading state: $_loading');
    DebugHelper.debugPrint('Denom is null: ${_denom == null}');
    DebugHelper.debugPrint('Vouchers count: ${_vouchers.length}');
    DebugHelper.debugPrint('Total harga: $totalHarga');
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Voucher'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: packageName == 'com.lariz.mobile'
            ? Theme.of(context).secondaryHeaderColor
            : Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: _selectDenom,
                    child: _denom == null
                        ? Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.5),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              border: Border.all(
                                color: Colors.grey,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'Klik Untuk Pilih Produk'.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(.15),
                                  offset: Offset(3, 3),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            width: double.infinity,
                            child: ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey.shade200,
                                child: CachedNetworkImage(
                                  imageUrl: widget.menu.icon,
                                  errorWidget: (_, __, ___) => SizedBox(),
                                ),
                              ),
                              title: Text(
                                _denom.nama,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(_denom.description),
                              trailing: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    formatRupiah(_isPromo
                                        ? _denom.harga_promo
                                        : _denom.harga_jual),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade600,
                                    ),
                                  ),
                                  _isPromo
                                      ? Text(
                                          formatRupiah(_denom.harga_jual),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.red.shade600,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        )
                                      : SizedBox(),
                                ],
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height: 15),
                  Expanded(
                    child: _content(),
                  ),
                ],
              ),
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.all(15),
          //   child: MaterialButton(
          //     minWidth: double.infinity,
          //     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          //     color: Theme.of(context).primaryColor,
          //     disabledColor: Colors.grey.shade200,
          //     colorBrightness: Brightness.dark,
          //     elevation: 0,
          //     shape: OutlineInputBorder(
          //         borderRadius: BorderRadius.circular(10),
          //         borderSide: BorderSide(color: Colors.grey)),
          //     child: _loading
          //         ? SpinKitThreeBounce(
          //             color: Colors.white,
          //             size: 20,
          //           )
          //         : Text(
          //             widget.menu.jenis == 5 ? 'Lanjutkan' : 'Proses Voucher'),
          //     onPressed: _denom == null ? null : _processVoucher,
          //   ),
          // ),
          Padding(
            padding: EdgeInsets.all(15),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              color: Colors.grey.withOpacity(.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total',
                            style: TextStyle(color: Colors.grey, fontSize: 11)),
                        SizedBox(height: 3),
                        Text(
                          formatRupiah(totalHarga),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: packageName == 'com.lariz.mobile'
                                ? Theme.of(context).secondaryHeaderColor
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: MaterialButton(
                      minWidth: double.infinity,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      color: packageName == 'com.lariz.mobile'
                          ? Theme.of(context).secondaryHeaderColor
                          : Theme.of(context).primaryColor,
                      disabledColor: Colors.grey.shade200,
                      colorBrightness: Brightness.dark,
                      elevation: 0,
                      shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey)),
                      child: _loading
                          ? SpinKitThreeBounce(color: Colors.white, size: 20)
                          : Text(widget.menu.jenis == 5
                              ? 'Lanjutkan'
                              : 'Proses Voucher'),
                      onPressed: _denom == null ? null : _processVoucher,
                    ),
                  )
                ],
              ),
            ),
            // child: MaterialButton(
            //   minWidth: double.infinity,
            //   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            //   color: Theme.of(context).primaryColor,
            //   disabledColor: Colors.grey.shade200,
            //   colorBrightness: Brightness.dark,
            //   elevation: 0,
            //   shape: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(10),
            //       borderSide: BorderSide(color: Colors.grey)),
            //   child: _loading
            //       ? SpinKitThreeBounce(
            //           color: Colors.white,
            //           size: 20,
            //         )
            //       : Text(
            //           widget.menu.jenis == 5 ? 'Lanjutkan' : 'Proses Voucher'),
            //   onPressed: _denom == null ? null : _processVoucher,
            // ),
          ),
        ],
      ),
    );
  }
}
