// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/mp_tracking.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:timeline_tile/timeline_tile.dart';

class LacakPesananPage extends StatefulWidget {
  final String orderId;
  LacakPesananPage(this.orderId);

  @override
  _LacakPesananPageState createState() => _LacakPesananPageState();
}

class _LacakPesananPageState extends State<LacakPesananPage> {
    @override
  void initState() {
    super.initState();
    analitycs.pageView('/lacak/pesanan', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Tracking MKP',
    });
  }

  Future<MPTracking> getTracking() async {
    http.Response response =
        await http.post(Uri.parse('$apiUrl/market/shipping/tracking'),
            headers: {
              'Authorization': bloc.token.valueWrapper?.value,
              'Content-Type': 'application/json'
            },
            body: json.encode({'id': widget.orderId}));

    if (response.statusCode == 200) {
      dynamic data = json.decode(response.body)['data'];

      if (data == null) {
        showToast(context, 'Gagal melacak paket');
        Navigator.of(context).pop();
        return null;
      }

      return MPTracking.fromJson(data);
    } else if (response.statusCode == 400) {
      showToast(context, 'Nomor resi tidak valid');
      Navigator.of(context).pop();
      return null;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(title: Text('Lacak Pengiriman'), elevation: 0),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(15),
        child: FutureBuilder<MPTracking>(
          future: getTracking(),
          builder: (ctx, snapshot) {
            if (!snapshot.hasData)
              return Center(
                  child: SpinKitThreeBounce(
                      color: Theme.of(context).primaryColor, size: 25));

            MPTracking item = snapshot.data;
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Kurir',
                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Text(item.kurir)
                    ]),
                SizedBox(height: 10),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Nomor Resi',
                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Text(item.resi)
                    ]),
                SizedBox(height: 10),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Status',
                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Text(item.status)
                    ]),
                SizedBox(height: 25),
                Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                        child: Text('RIWAYAT PENGIRIMAN',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor)))),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: item.manifests.length,
                    itemBuilder: (ctx, i) {
                      MPTrackingManifest mf = item.manifests[i];

                      return TimelineTile(
                        isFirst: (i == 0),
                        isLast: (i == item.manifests.length - 1),
                        indicatorStyle: IndicatorStyle(
                          color: i == 0 ? Colors.green : Colors.grey,
                          iconStyle: IconStyle(
                            iconData: Icons.check,
                            color: Colors.white,
                          ),
                        ),
                        beforeLineStyle: LineStyle(color: Colors.grey),
                        endChild: Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mf.description,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: i == 0 ? Colors.black87 : Colors.grey,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                formatDate(mf.timestamp, 'd MMM yyyy - HH:mm'),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
