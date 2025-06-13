// @dart=2.9

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends ContactPageController {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: search
              ? TextFormField(
                  autofocus: true,
                  controller: nama,
                  keyboardType: TextInputType.text,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(border: InputBorder.none),
                  onChanged: (value) => getContact(),
                )
              : Text(
                  'Pilih Kontak',
                ),
          centerTitle: true,
          elevation: 0,
          actions: <Widget>[
            search
                ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        nama.clear();
                        getContact();
                        search = false;
                      });
                    },
                  )
                : IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        search = !search;
                      });
                    })
          ]),
      body: Container(
          width: double.infinity,
          height: double.infinity,
          child: loading
              ? loadingWidget()
              : ListView.separated(
                  itemCount: contacts.length,
                  separatorBuilder: (_, i) => Divider(),
                  itemBuilder: (context, i) {
                    return InkWell(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(contacts[i]['name'],
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(contacts[i]['phone'],
                                  style: TextStyle(color: Colors.grey))
                            ]),
                      ),
                      onTap: () {
                        String phone = contacts[i]['phone']
                            .replaceAll('+62', '0')
                            .replaceAll(' ', '')
                            .replaceAll('-', '');
                        Navigator.of(context).pop(phone);
                      },
                    );
                  },
                )),
    );
  }
}

abstract class ContactPageController extends State<ContactPage> {
  bool loading = false;
  bool search = false;
  TextEditingController nama = TextEditingController();
  List<Map<String, String>> contacts = [];

  @override
  void initState() {
    getContact();
    super.initState();
  }

  checkPermission() async {
    bool status = false;
    PermissionStatus permStatus = await Permission.contacts.request();
    while (permStatus != PermissionStatus.granted) {
      permStatus = await Permission.contacts.request();
    }

    if (permStatus == PermissionStatus.granted) status = true;
    return status;
  }

  void getContact() async {
    if (await checkPermission()) {
      Iterable<Contact> datas = [];
      if (nama.text.length > 0) {
        datas = await ContactsService.getContacts(
          withThumbnails: false,
          query: nama.text,
        );
      } else {
        datas = await ContactsService.getContacts(withThumbnails: false);
      }
      contacts.clear();
      datas.toList().forEach((data) {
        data.phones.forEach((item) {
          contacts.add({'name': data.displayName, 'phone': item.value});
        });
      });
    }
    if (this.mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Widget loadingWidget() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Center(
          child: SpinKitThreeBounce(
              color: Theme.of(context).primaryColor, size: 35)),
    );
  }
}
