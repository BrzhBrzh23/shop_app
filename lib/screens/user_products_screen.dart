import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';
  const UserProductsScreen({super.key});

  Future refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Your products'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(EditProduct.routeName, arguments: '');
                },
                icon: Icon(Icons.add))
          ],
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
            future: refreshProducts(context),
            builder: (context, snapshot) => snapshot.connectionState ==
                    ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Consumer<Products>(builder: (context, products, _) {
                    return RefreshIndicator(
                      onRefresh: () => refreshProducts(context),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                          itemBuilder: (context, index) => Column(
                            children: [
                              UserProductItem(product: products.items[index]),
                              Divider(),
                            ],
                          ),
                          itemCount: products.items.length,
                        ),
                      ),
                    );
                  })));
  }
}
