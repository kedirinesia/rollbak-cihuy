
import 'package:flutter/material.dart';
import 'package:mobile/Products/paymobileku/layout/invite/invite_qrcode.dart';
import 'package:mobile/Products/paymobileku/layout/invite/invite_wrapper.style.dart';
import 'package:mobile/utils/style_helper.dart';

class InviteWrapper extends StatefulWidget {
  Uri inviteLink;
  bool loading;
  Function getUserInfo;
  InviteWrapper({required this.inviteLink, required this.loading, required this.getUserInfo, Key? key})
      : super(key: key);

  @override
  State<InviteWrapper> createState() => _InviteWrapperState();
}

class _InviteWrapperState extends State<InviteWrapper> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: InviteWrapperStyle.wrapperMargin,
      child: StyleHelper.styledContainer(
        padding: InviteWrapperStyle.wrapperPadding,
        decoration: InviteWrapperStyle.wrapperDecoration,
        child: InviteQRCode(
          inviteLink: widget.inviteLink,
          loading: widget.loading,
          getUserInfo: widget.getUserInfo,
        ),
      ),
    );
  }
}
