import 'package:flutter/material.dart';
import 'package:mobile/Products/paymobileku/layout/transfer-bank/daftar_transfer.dart';

class TransferOptionPage extends StatefulWidget {
  const TransferOptionPage({Key? key}) : super(key: key);

  @override
  State<TransferOptionPage> createState() => _TransferOptionPageState();
}

class _TransferOptionPageState extends State<TransferOptionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transfer'),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pushNamed('/transfer'),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(.15),
                    offset: Offset(3, 3),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: Theme.of(context).primaryColor,
                  child: Icon(Icons.account_balance_wallet),
                ),
                title: Text(
                  'Transfer ke Member Lain',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text('Kirim saldo ke member lain'),
                trailing: Icon(Icons.navigate_next),
              ),
            ),
          ),
          SizedBox(height: 15),
          InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DaftarTransferPage(),
              ),
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(.15),
                    offset: Offset(3, 3),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: Theme.of(context).primaryColor,
                  child: Icon(Icons.account_balance_rounded),
                ),
                title: Text(
                  'Transfer ke Rekening Bank',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text('Tarik saldo ke rekening bank'),
                trailing: Icon(Icons.navigate_next),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
