// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/mp_kategori.dart';
import 'package:mobile/screen/marketplace/list_produk.dart';

class MoreCategoriesPage extends StatefulWidget {
  List<CategoryModel> categories;

  MoreCategoriesPage(this.categories, {Key key}) : super(key: key);

  @override
  State<MoreCategoriesPage> createState() => _MoreCategoriesPageState();
}

class _MoreCategoriesPageState extends State<MoreCategoriesPage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
        title: Text('Semua Kategori'),
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade200,
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        height: double.infinity,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemCount: widget.categories.length,
          itemBuilder: (BuildContext context, int index) {
            CategoryModel category = widget.categories[index];
            return InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ListProdukMarketplace(
                    searchQuery: category.judul,
                  ),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(3)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(3),
                              topRight: Radius.circular(3),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: category.thumbnailUrl,
                              fit: BoxFit.cover,
                            ),
                          )),
                    ),
                    Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      // color: Color(0xff438eba),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          stops: [
                            0.2,
                            0.4,
                          ],
                          colors: [
                            Color(0xff0dade8),
                            Theme.of(context).primaryColor.withOpacity(0.9),
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(3),
                            bottomRight: Radius.circular(3)),
                      ),
                      child: Center(
                        child: FittedBox(
                          child: Text(
                            category.judul,
                            maxLines: 1,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
