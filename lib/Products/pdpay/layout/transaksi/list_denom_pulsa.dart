import 'package:flutter/material.dart';
import 'package:mobile/models/pulsa.dart';
import 'package:mobile/modules.dart';

class ListDenomPulsaPage extends StatefulWidget {
  final List<PulsaModel> denoms;
  ListDenomPulsaPage(this.denoms);

  @override
  _ListDenomPulsaPageState createState() => _ListDenomPulsaPageState();
}

class _ListDenomPulsaPageState extends State<ListDenomPulsaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Denom Tersedia'),
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade100,
      body: ListView.separated(
        padding: EdgeInsets.all(15),
        itemCount: widget.denoms.length,
        separatorBuilder: (_, __) => SizedBox(height: 10),
        itemBuilder: (_, i) {
          PulsaModel denom = widget.denoms.elementAt(i);

          return InkWell(
            onTap: () => Navigator.of(context).pop(denom),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    offset: Offset(3, 3),
                    blurRadius: 15,
                  ),
                ],
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      denom.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Harga',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        formatRupiah(denom.hargaJual),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
