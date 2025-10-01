import 'package:flutter/material.dart';
import 'package:mobile/Products/centralbayar/layout/components/moremenu.dart';

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
