import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/order_tile.dart';

import '../providers/orders_provider.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders-screen';
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future? _futureOrders;

  Future getFutureOrders() =>
      Provider.of<Orders>(context, listen: false).fetchOrders();

  @override
  void initState() {
    _futureOrders = getFutureOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Orders')),
      drawer: AppDrawer(),
      body: FutureBuilder(
          future: _futureOrders,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Text('No Orders');
            } else {
              return Consumer<Orders>(builder: (context, ordersData, child) {
                return ListView.builder(
                  itemBuilder: (ctx, index) =>
                      OrderTile(order: ordersData.orders[index]),
                  itemCount: ordersData.orders.length,
                );
              });
            }
          }),
    );
  }
}
