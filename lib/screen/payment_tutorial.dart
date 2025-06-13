import 'package:flutter/material.dart';
import 'package:mobile/config.dart';

class PaymentTutorialPage extends StatefulWidget {
  @override
  State<PaymentTutorialPage> createState() => _PaymentTutorialPageState();
}

class _PaymentTutorialPageState extends State<PaymentTutorialPage> {
  List<Map<String, dynamic>> _tutorials = [];

  @override
  void initState() {
    super.initState();

    _tutorials = [
      {
        'title': 'Transfer Bank',
        'expanded': false,
        'contents': [
          {
            'title': 'ATM',
            'steps': [
              'Masukkan kartu ATM ke dalam mesin ATM',
              'Ketik PIN ATM anda',
              'Pilih menu "Transfer"',
              'Masukkan nomor rekening tujuan beserta dengan kode bank tujuan',
              'Masukkan nominal transfer yang sudah ditentukan',
              'Konfirmasi nama rekening apakah sudah sama dengan nama yang tertera di atas',
              'Simpan struk atau email sebagai bukti transaksi anda',
            ],
          },
          {
            'title': 'Mobile Banking',
            'steps': [
              'Buka aplikasi Mobile Banking anda',
              'Masuk dengan akun Mobile Banking anda',
              'Pilih menu "Transfer"',
              'Pilih bank tujuan',
              'Masukkan nomor rekening tujuan',
              'Konfirmasi nama pemilik rekening tujuan',
              'Masukkan nominal transfer yang sudah ditentukan',
              'Masukkan PIN anda',
              'Simpan bukti transfer',
            ],
          },
        ]
      },
      {
        'title': 'eWallet',
        'expanded': false,
        'contents': [
          {
            'title': 'DANA / OVO / ShopeePay / GoPay / dll',
            'steps': [
              'Buka aplikasi eWallet anda',
              'Pilih menu "Kirim" atau "Transfer"',
              'Masukkan nomor eWallet tujuan',
              'Konfirmasi nama penerima sesuai dengan nama yang tercantum di atas',
              'Masukkan nominal transfer yang sudah ditentukan',
              'Simpan bukti transfer',
            ],
          },
        ]
      },
      {
        'title': 'Virtual Account (VA)',
        'expanded': false,
        'contents': [
          {
            'title': 'ATM',
            'steps': [
              'Masukkan kartu ATM anda ke mesin ATM',
              'Pilih menu "Transaksi Lain > Pembayaran > Lainnya > Virtual Account"',
              'Masukkan kode VA yang tertera di atas',
              'Masukkan nominal transfer yang sudah ditentukan (bila ada)',
              'Konfirmasi nama Virtual Account tujuan',
              'Konfirmasi transaksi',
              'Simpan bukti pembayaran',
            ],
          },
          {
            'title': 'Mobile Banking',
            'steps': [
              'Buka aplikasi Mobile Banking anda',
              'Masuk dengan akun Mobile Banking anda',
              'Pilih menu "Virtual Account"',
              'Masukkan kode Virtual Account',
              'Konfirmasi nama Virtual Account tujuan',
              'Masukkan nominal transfer yang sudah ditentukan (bila ada)',
              'Masukkan PIN anda',
              'Simpan bukti pembayaran',
            ],
          },
          {
            'title': 'Livin` by Mandiri',
            'steps': [
              'Login aplikasi Livin` by Mandiri',
              'Pilih menu "Bayar"',
              'Cari (87827) atau cari (LINKQU-BILL) sebagai Penyedia Jasa',
              'Masukkan Nomor Virtual Account, (contoh: 87827XXXXXXX)',
              'Pilih Lanjutkan',
              'Masukkan jumlah transfer sesuai dengan tagihan kamu. Jumlah yang berbeda tidak dapat diproses',
              'Layar menampilkan Kode Bayar dan Data Pembayaran',
              'Jika datanya benar, Klik Lanjutkan',
              'Masukkan PIN New Livin, Klik OK',
              'Pembayaran selesai',
            ],
          },
        ]
      },
      {
        'title': 'QRIS',
        'expanded': false,
        'contents': [
          {
            'title': 'eWallet',
            'steps': [
              'Buka aplikasi eWallet anda',
              'Pilih menu "Scan" / "Pindai" / "Kirim"',
              'Pindai kode QR yang tampil pada detail transaksi di atas',
              'Konfirmasi nama penerima',
              'Masukkan nominal transfer yang sudah ditentukan',
              'Masukkan PIN anda',
              'Simpan bukti transaksi',
            ],
          },
        ]
      },
      {
        'title': 'Outlet',
        'expanded': false,
        'contents': [
          {
            'title': 'Indomaret / Alfamart / Alfamidi',
            'steps': [
              'Datang ke gerai / outlet terkait',
              'Beritahu kasir untuk melakukan pembayaran "LINKITA"',
              'Tunjukkan kode pembayaran ke kasir atau operator',
              'Simpan bukti transaksi',
            ],
          },
        ]
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.15),
            offset: Offset(3, 3),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cara Pembayaran'.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: packageName == 'com.lariz.mobile'
                  ? Theme.of(context).secondaryHeaderColor
                  : Theme.of(context).primaryColor,
            ),
          ),
          Divider(),
          ExpansionPanelList(
            elevation: 0,
            expandedHeaderPadding: EdgeInsets.zero,
            expansionCallback: (i, isExpanded) => setState(() {
              _tutorials[i]['expanded'] = !isExpanded;
            }),
            children: _tutorials.map((e) {
              return ExpansionPanel(
                isExpanded: e['expanded'],
                backgroundColor: e['expanded']
                    ? packageName == 'com.lariz.mobile'
                        ? Theme.of(context)
                            .secondaryHeaderColor
                            .withOpacity(.05)
                        : Theme.of(context).primaryColor.withOpacity(.05)
                    : Theme.of(context).cardColor,
                headerBuilder: (_, __) => InkWell(
                  onTap: () => setState(() {
                    _tutorials[_tutorials.indexOf(e)]['expanded'] =
                        !e['expanded'];
                  }),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e['title'],
                          style: TextStyle(
                            fontWeight: e['expanded']
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: e['expanded']
                                ? packageName == 'com.lariz.mobile'
                                    ? Theme.of(context).secondaryHeaderColor
                                    : Theme.of(context).primaryColor
                                : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                body: Container(
                  padding: EdgeInsets.all(10),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: e['contents'].length,
                    separatorBuilder: (_, __) => Divider(),
                    itemBuilder: (_, index) {
                      Map<String, dynamic> content = e['contents'][index];

                      return ListView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          Text(
                            content['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          SizedBox(height: 5),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: content['steps'].length,
                            separatorBuilder: (_, __) => SizedBox(height: 5),
                            itemBuilder: (_, j) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${j + 1}.'),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      content['steps'][j],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
