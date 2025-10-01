// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:mobile/Products/alpay/layout/components/menu_tools/main.style.dart';
import 'package:mobile/Products/alpay/layout/components/menu_tools/menu_tools_wrapper.dart';

class MenuTools extends StatefulWidget {
  @override
  _MenuToolsState createState() => _MenuToolsState();
}

class _MenuToolsState extends State<MenuTools> {
  @override
  Widget build(BuildContext context) {
    return Parent(
      style: MenuToolsStyle.wrapper,
      child: MenuWrapper(),
    );
  }
}
