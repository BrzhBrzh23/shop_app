import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/product_detail.dart';

import '../models/product_model.dart';
import '../providers/auth.dart';
import '../providers/cart_provider.dart';

class ProductItem extends StatelessWidget {
  // final Product product;
  // ProductItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Consumer<Product>(builder: (context, product, child) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridTile(
          footer: GridTileBar(
            leading: IconButton(
              color: Theme.of(context).accentColor,
              icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: () {
                product.toggleFavorite(
                  Provider.of<Auth>(context, listen: false).token,
                  Provider.of<Auth>(context, listen: false).userId,
                );
              },
            ),
            trailing: Consumer<Cart>(builder: (context, cart, child) {
              return IconButton(
                color: Theme.of(context).accentColor,
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  cart.addItem(product.id, product.title, product.price);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added item to a cart!'),
                      duration: Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {
                          cart.removeSingleItem(product.id);
                        },
                      ),
                    ),
                  );
                },
              );
            }),
            title: Text(
              product.title,
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.black87,
          ),
          child: GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pushNamed(ProductDetail.routeName, arguments: product.id);
              },
              child: Hero(
                tag: product.id,
                child: FadeInImage(
                  placeholder:
                      AssetImage('assets/images/product-placeholder.png'),
                  image: NetworkImage(
                    product.imageUrl,
                  ),
                  fit: BoxFit.cover,
                ),
              )),
        ),
      );
    });
  }
}
