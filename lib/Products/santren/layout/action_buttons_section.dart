// @dart=2.9

import 'package:flutter/material.dart';
import 'package:mobile/Products/santren/layout/qris/qris_page.dart';
import 'package:mobile/Products/santren/layout/transfer.dart';

class ActionButtonsSection extends StatelessWidget {
  const ActionButtonsSection({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFF0652DD),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => QrisPage()));
              },
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xFF0652DD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(0.5),
                      child: Image.asset(
                        'assets/img/santren/iconatas1.PNG',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Text(
                    'QRIS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => Navigator.of(context).pushNamed('/topup'),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xFF0652DD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(6),
                      child: Image.asset(
                        'assets/img/santren/iconatas2.PNG',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Text(
                    'Top Up',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => TransferManuPage()));
              },
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xFF0652DD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(6),
                      child: Image.asset(
                        'assets/img/santren/iconatas3.PNG',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Text(
                    'Transfer',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => Navigator.of(context).pushNamed('/withdraw'),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xFF0652DD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(6),
                      child: Image.asset(
                        'assets/img/santren/iconatas4.PNG',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Text(
                    'Tarik',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
