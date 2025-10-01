
import 'package:flutter/material.dart';

class InviteFriendBanner extends StatelessWidget {
  const InviteFriendBanner({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.02),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Color(0xFF0652DD),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text(
                    "Undang Teman anda sebanyak banyaknya Dapat Bonus referal 10.000 dan komisi transaksi downline anda",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
            SizedBox(width: 16),
            // Icon
            Icon(
              Icons.person_add_alt_1_outlined,
              color: Colors.white,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}
