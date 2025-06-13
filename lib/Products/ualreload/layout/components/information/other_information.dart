// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:mobile/Products/ualreload/layout/components/information/other_information.style.dart';
import 'package:mobile/models/info.dart';
import 'package:mobile/screen/info/info.dart';

class OtherInformation extends StatefulWidget {
  final List<InfoModel> informations;
  const OtherInformation(this.informations, {Key key}) : super(key: key);

  @override
  State<OtherInformation> createState() => OtherInformationState();
}

class OtherInformationState extends State<OtherInformation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informasi Lainnya'),
        elevation: 0,
      ),
      body: ListView.separated(
          padding: EdgeInsets.symmetric(vertical: 20),
          itemBuilder: (BuildContext context, int index) {
            InfoModel info = widget.informations[index];
            return InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => InfoPage(info),
                ),
              ),
              child: Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        offset: const Offset(0.0, 2.1),
                        blurRadius: 1.0,
                        spreadRadius: 0.2,
                      ),
                      BoxShadow(
                        color: Colors.grey.shade300,
                        offset: const Offset(-0.1, -0.1),
                        blurRadius: 1.0,
                        spreadRadius: 0.2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                          child: CachedNetworkImage(
                            width: double.infinity,
                            height: 160,
                            imageUrl: info.icon,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Txt(
                                info.title,
                                style: OtherInformationStyle.text.clone()
                                  ..fontSize(16)
                                  ..fontWeight(
                                    FontWeight.bold,
                                  ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              child: Txt(
                                info.description,
                                style: OtherInformationStyle.text.clone()
                                  ..maxLines(2),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int _) =>
              SizedBox(height: 50, child: Divider()),
          itemCount: widget.informations.length),
    );
  }
}
