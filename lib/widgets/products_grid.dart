import 'package:flutter/material.dart';
import 'package:shop_app/widgets/product_item.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/products_provider.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavorite;
  ProductsGrid(this.showFavorite);
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products =
        showFavorite ? productsData.favoriteItems : productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => ChangeNotifierProvider.value(
        value: products[index],
        child: ProductItem(),
      ),
    );
  }
}
