import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CartTile extends StatelessWidget {
  final CartItem cart;
  final String idKey;
  const CartTile({super.key, required this.cart, required this.idKey});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Are you sure?',
            ),
            content: Text('Do you want to remove the item?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('No')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text('Yes'))
            ],
          ),
        );
      },
      direction: DismissDirection.endToStart,
      onDismissed: ((direction) =>
          Provider.of<Cart>(context, listen: false).removeItem(idKey)),
      key: ValueKey(cart),
      background: Container(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        color: Theme.of(context).errorColor,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(
          Icons.delete,
          size: 40,
          color: Colors.white,
        ),
      ),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: FittedBox(child: Text('\$ ${cart.price}')),
              ),
            ),
            title: Text(cart.title),
            subtitle: Text('Total: \$ ${cart.price * cart.quantity}'),
            trailing: Text('${cart.quantity} x'),
          ),
        ),
      ),
    );
  }
}
