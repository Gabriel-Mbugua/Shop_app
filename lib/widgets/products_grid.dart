import 'package:flutter/material.dart';

import 'package:shop_app/providers/products.dart';
import 'package:shop_app/widgets/product_item.dart';
import 'package:provider/provider.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;

  ProductsGrid(this.showFavs);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products = showFavs ? productsData.favouriteItems : productsData.items ;
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, //amount of columns
          childAspectRatio: 3 / 2, //dimensions of a grid item
          crossAxisSpacing: 10, //spacing between the items
          mainAxisSpacing: 10),
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
//        builder: (c) => products[index],
        value: products[index],
        child: ProductItem(
//            products[index].id,
//            products[index].title,
//            products[index].imageUrl
        ),
      ),
      itemCount: products.length,
    );
  }
}