// @dart=2.9

import 'package:flutter/material.dart';
import 'package:mobile/Products/mykonter/layout/topup.dart';
import 'package:mobile/Products/mykonter/layout/transfer.dart';
import 'package:mobile/screen/profile/invite/invite.dart';

class Panel extends StatelessWidget {
  Widget builder({
    @required BuildContext context,
    @required Widget page,
    @required IconData icon,
    @required String title,
  }) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => page,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(.25),
              blurRadius: 15,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.grey.shade600,
              size: 15,
            ),
            SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: [
          builder(
            context: context,
            icon: Icons.add_circle_rounded,
            title: 'Isi Ulang',
            page: TopupPage(),
          ),
          SizedBox(width: 10),
          builder(
            context: context,
            icon: Icons.supervisor_account_rounded,
            title: 'Ajak Teman',
            page: InvitePage(),
          ),
          SizedBox(width: 10),
          builder(
            context: context,
            icon: Icons.swap_vertical_circle_rounded,
            title: 'Transfer',
            page: TransferPagePopay(),
          ),
        ],
      ),
    );
  }
}
