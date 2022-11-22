import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/edit_product_screen.dart';

import '../models/product_model.dart';

class UserProductItem extends StatelessWidget {
  final Product product;
  const UserProductItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final scaffoldContext = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(product.title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(product.imageUrl),
      ),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
            color: Theme.of(context).primaryColor,
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(EditProduct.routeName, arguments: product.id);
            },
            icon: Icon(Icons.edit)),
        Consumer<Products>(builder: (context, products, child) {
          return IconButton(
              color: Theme.of(context).errorColor,
              onPressed: () async {
                try {
                  await products.deleteProduct(product.id);
                } catch (e) {
                  scaffoldContext.showSnackBar(
                      const SnackBar(content: Text('Deleting failed')));
                }
              },
              icon: Icon(Icons.delete));
        }),
      ]),
    );
  }
}
