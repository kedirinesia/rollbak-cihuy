// @dart=2.9
import 'package:flutter/material.dart';
import 'package:mobile/Products/funfast/layout/more/more.dart';
import 'package:mobile/utils/debug_helper.dart';

abstract class MorePageModel extends State<MorePage>
    with TickerProviderStateMixin {
  bool isSearching = false;
  TextEditingController q = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  klikSearch() {
    setState(() {
      isSearching = true;
    });
  }
}
