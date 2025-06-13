// @dart=2.9

import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile/Products/alpay/layout/invite/invite_generate_referal_code.dart';
import 'package:mobile/Products/alpay/layout/invite/invite_referal_code_info.style.dart';
import 'package:mobile/models/user.dart';

class InviteReferalCodeInfo extends StatelessWidget {
  Function getUserInfo;
  InviteReferalCodeInfo(this.getUserInfo, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Parent(
      style: InviteReferalCodeInfoStyle.wrapper,
      child: ValueListenableBuilder(
        valueListenable: Hive.box('ref-code').listenable(),
        builder: (context, value, child) {
          var user = value.length != 0 ? UserModel.parse(value.getAt(0)) : null;

          return Row(
            children: [
              Expanded(
                child: user != null
                    ? Text(
                        user.inviteCode,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      )
                    : Text(
                        '-----------------',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
              Expanded(
                child: Row(
                  children: [
                    user != null
                        ? InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(
                                  text: user.inviteCode != ''
                                      ? user.inviteCode
                                      : '-----------------'));
                              final snackBar = SnackBar(
                                content: const Text(
                                    'Kode Referal berhasil disalin ke papan klip'),
                              );

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            },
                            child: Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.copy,
                                  size: 20,
                                ),
                                SizedBox(width: 5),
                                Text('Copy'),
                              ],
                            ),
                          )
                        : Container(
                            child: Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.copy,
                                  size: 20,
                                ),
                                SizedBox(width: 5),
                                Text('Copy'),
                              ],
                            ),
                          ),
                    SizedBox(width: 15),
                    GenerateRefCode(this.getUserInfo),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
