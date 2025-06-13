// @dart=2.9

import 'package:flutter/material.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/profile/edit/edit_user-controller.dart';

class EditUser extends StatefulWidget {
  @override
  _EditUserState createState() => _EditUserState();
}

class _EditUserState extends EditUserController {
  @override
  void initState() {
    super.initState();
    analitycs.pageView('/edit/user', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Edit User',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          iconTheme: IconThemeData(color: Colors.white),
          expandedHeight: 200.0,
          backgroundColor: Theme.of(context).primaryColor,
          pinned: true,
          flexibleSpace:
              FlexibleSpaceBar(title: Text('Edit User'), centerTitle: true),
        ),
        SliverList(
            delegate: SliverChildListDelegate([
          Container(
              padding: EdgeInsets.all(15),
              child: Column(children: <Widget>[
                TextFormField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                        labelText: 'Nama'),
                    keyboardType: TextInputType.text,
                    controller: nama),
                SizedBox(height: 15),
                TextFormField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.store),
                        labelText: 'Nama Merchant'),
                    keyboardType: TextInputType.text,
                    controller: namaMerchant),
                SizedBox(height: 15),
                TextFormField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                        labelText: 'Alamat'),
                    keyboardType: TextInputType.text,
                    controller: alamat),
                SizedBox(height: 15),
                ButtonTheme(
                  minWidth: double.infinity,
                  child: MaterialButton(
                      child: Text('Ubah Nomor HP'.toUpperCase()),
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      shape: StadiumBorder(),
                      onPressed: () {}),
                ),
                ButtonTheme(
                  minWidth: double.infinity,
                  child: MaterialButton(
                      child: Text('Simpan'.toUpperCase()),
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      shape: StadiumBorder(),
                      onPressed: () {}),
                )
              ]))
        ]))
      ]),
    );
  }
}
