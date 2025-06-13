// @dart=2.9

import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:mobile/Products/xenaja/layout/invite/invite_qrcode.dart';
import 'package:mobile/Products/xenaja/layout/invite/invite_wrapper.style.dart';

class InviteWrapper extends StatefulWidget {
  Uri inviteLink;
  bool loading;
  Function getUserInfo;
  InviteWrapper({this.inviteLink, this.loading, this.getUserInfo, Key key})
      : super(key: key);

  @override
  State<InviteWrapper> createState() => _InviteWrapperState();
}

class _InviteWrapperState extends State<InviteWrapper> {
  @override
  Widget build(BuildContext context) {
    return Parent(
      style: InviteWrapperStyle.wrapper,
      child: InviteQRCode(
        inviteLink: widget.inviteLink,
        loading: widget.loading,
        getUserInfo: widget.getUserInfo,
      ),
    );
  }
}
