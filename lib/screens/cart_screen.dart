import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/orders_provider.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/widgets/cart_item.dart';

import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart-screen';
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your cart'),
      ),
      body: Consumer2<Cart, Orders>(builder: (context, cart, orders, child) {
        return Column(children: <Widget>[
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Chip(
                      label: Text(
                        '\$ ${cart.totalAmount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    OrderWidget()
                  ],
                )),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
              child: ListView.builder(
            itemBuilder: (context, index) => CartTile(
                idKey: cart.items.keys.toList()[index],
                cart: cart.items.values.toList()[index]),
            itemCount: cart.itemCount,
          ))
        ]);
      }),
    );
  }
}

class OrderWidget extends StatefulWidget {
  const OrderWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  var isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Consumer2<Cart, Orders>(builder: (context, cart, orders, child) {
      return TextButton(
        onPressed: (cart.totalAmount <= 0) || isLoading == true
            ? null
            : () async {
                setState(() {
                  isLoading = true;
                });
                await orders.addOrder(
                    cart.items.values.toList(), cart.totalAmount);
                cart.clear();
                Navigator.of(context).pushNamed(OrdersScreen.routeName);
              },
        child: isLoading
            ? const CircularProgressIndicator()
            : const Text('ORDER NOW'),
      );
    });
  }
}
