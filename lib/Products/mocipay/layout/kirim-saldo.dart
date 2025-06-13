import 'package:flutter/material.dart';
import 'package:mobile/Products/popay/layout/components/template.dart';
import 'package:mobile/component/contact.dart';
import 'package:mobile/screen/transfer_saldo/transfer_by_qr.dart';

class KirimSaldo extends StatefulWidget {
  @override
  _KirimSaldoState createState() => _KirimSaldoState();
}

class _KirimSaldoState extends State<KirimSaldo> {
  final TextEditingController nomorTujuan = TextEditingController();

  void cek() {
    if (nomorTujuan.text.length != 0) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => TransferByQR(nomorTujuan.text)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return TemplatePopay(
      title: 'Kirim Saldo',
      height: 200.0,
      body: ListView(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(.1),
                      offset: Offset(5, 10),
                      blurRadius: 10.0)
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Nomor Tujuan',
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 10.0),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  controller: nomorTujuan,
                  autofocus: true,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.phone),
                      // suffixIcon: IconButton(
                      //     icon: Icon(Icons.contacts),
                      //     onPressed: () {
                      //       Navigator.of(context)
                      //           .push(MaterialPageRoute(
                      //               builder: (_) => ContactPage()))
                      //           .then((nomor) {
                      //         if (nomor != null) {
                      //           nomorTujuan.text = nomor;
                      //         }
                      //       });
                      //     }),
                      contentPadding: EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0))),
                ),
                SizedBox(height: 20.0),
                TextButton(
                  onPressed: cek,
                  child: Text(
                    'Selanjutnya',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
