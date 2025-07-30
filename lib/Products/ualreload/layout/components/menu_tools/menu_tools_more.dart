// @dart=2.9

import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/Products/ualreload/layout/kirim_saldo.dart';
import 'package:mobile/Products/ualreload/layout/components/menu_tools/menu_tools_more.style.dart';

class MenuToolsMore extends StatelessWidget {
  const MenuToolsMore({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
              ),
              isScrollControlled: true,
              builder: (BuildContext context) {
                return Parent(
                  style: ParentStyle()
                    ..height(MediaQuery.of(context).size.height * 0.17)
                    ..padding(vertical: 13, horizontal: 20),
                  child: Column(
                    children: [
                      Parent(
                        style: MenuToolsMoreStyle.swapper,
                        child: Container(),
                      ),
                      SizedBox(height: 10),
                      Container(
                        child: GridView(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.all(0),
                          children: [
                            // Container(
                            //   child: InkWell(
                            //     onTap: () {
                            //       Navigator.of(context).push(
                            //         MaterialPageRoute(
                            //           builder: (_) => DaftarTransferPage(),
                            //         ),
                            //       );
                            //     },
                            //     child: Column(
                            //       mainAxisAlignment: MainAxisAlignment.center,
                            //       children: <Widget>[
                            //         Parent(
                            //           style: MenuToolsMoreStyle.iconWrapper,
                            //           child: SvgPicture.asset(
                            //             'assets/img/payuni2/send.svg',
                            //             color: Theme.of(context).primaryColor,
                            //           ),
                            //         ),
                            //         SizedBox(height: 2),
                            //         Txt(
                            //           'Transfer Bank',
                            //           style: MenuToolsMoreStyle.text,
                            //         )
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            Container(
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => KirimSaldo(),
                                    ),
                                  );
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Parent(
                                      style: MenuToolsMoreStyle.iconWrapper,
                                      child: SvgPicture.asset(
                                        'assets/img/payuni2/send.svg',
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Txt(
                                      'Transfer Saldo',
                                      style: MenuToolsMoreStyle.text,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              child: InkWell(
                                onTap: () =>
                                    Navigator.of(context).pushNamed('/myqr'),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Parent(
                                      style: MenuToolsMoreStyle.iconWrapper,
                                      child: SvgPicture.asset(
                                        'assets/img/payuni2/accept.svg',
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Txt(
                                      'Terima Saldo',
                                      style: MenuToolsMoreStyle.text,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 10,
                            childAspectRatio: .95,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: Container(
            // color: Colors.amber,
            margin: const EdgeInsets.only(right: 10.0),
            child: Icon(
              Icons.more_vert,
              color: Theme.of(context).primaryColor.withOpacity(.55),
            ),
          ),
        ),
      ),
    );
  }
}
