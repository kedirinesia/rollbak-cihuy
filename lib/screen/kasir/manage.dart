import 'package:flutter/material.dart';

class Manage extends StatefulWidget {
  @override
  createState() => ManageState();
}

class ManageState extends State<Manage> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        title: Text('Manajemen'),
      ),
    );
  }
}
