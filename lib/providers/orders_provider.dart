import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.dateTime});
}

class Orders with ChangeNotifier {
  final String token;
  final String userId;

  List<OrderItem> _orders = [];

  Orders(this.token, this._orders, this.userId);


  List<OrderItem> get orders {
    return [..._orders];
  }

  Future fetchOrders() async {
    final url = Uri.parse(
        'https://my-project-c0d2a-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token');
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData.isEmpty) return;
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
          id: orderId,
          amount: orderData['amount'],
          products: (orderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                  id: item['id'],
                  title: item['title'],
                  quantity: item['quantity'],
                  price: item['price']))
              .toList(),
          dateTime: DateTime.parse(orderData['dateTime'])));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
    print(json.decode(response.body));
  }

  Future addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://my-project-c0d2a-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token');
    final timeStamp = DateTime.now();
    try {
      final response = await http.post(url,
          body: json.encode({
            'amount': total,
            'products': cartProducts
                .map((cp) => {
                      'id': cp.id,
                      'title': cp.title,
                      'quantity': cp.quantity,
                      'price': cp.price
                    })
                .toList(),
            'dateTime': timeStamp.toIso8601String(),
          }));
      final newOrder = OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        products: cartProducts,
        dateTime: timeStamp,
      );
      _orders.insert(0, newOrder);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
