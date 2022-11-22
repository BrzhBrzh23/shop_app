import 'dart:math';

import 'package:flutter/material.dart';

import '../providers/orders_provider.dart';
import 'package:intl/intl.dart';

class OrderTile extends StatefulWidget {
  final OrderItem order;
  const OrderTile({super.key, required this.order});

  @override
  State<OrderTile> createState() => _OrderTileState();
}

class _OrderTileState extends State<OrderTile> {
  var expanded = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: expanded ? min(widget.order.products.length * 20 + 110, 200) : 95,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              title: Text('\$ ${widget.order.amount}'),
              subtitle:
                  Text(DateFormat('dd/MM/yyyy').format(widget.order.dateTime)),
              trailing: IconButton(
                icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    expanded = !expanded;
                  });
                },
              ),
            ),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 4,
                ),
                height: expanded ? min(widget.order.products.length * 20 + 10, 100) : 0,
                child: ListView.builder(
                  itemCount: widget.order.products.length,
                  itemBuilder: (context, index) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.order.products[index].title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.order.products[index].quantity}x \$${widget.order.products[index].price}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      )
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
