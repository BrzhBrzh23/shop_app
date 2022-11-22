import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/error/exception.dart';
import '../models/product_model.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [
    Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
  ];

  final String authToken;
  final String userId;

  Products(this.authToken, this._items, this.userId);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future fetchProducts([bool filterByUser = false]) async {
    final String filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = Uri.parse(
        'https://my-project-c0d2a-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData.isEmpty) return;

      url = Uri.parse(
          'https://my-project-c0d2a-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken');
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);

      final loadedProducts = <Product>[];

      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          price: prodData['price'],
          title: prodData['title'],
          description: prodData['description'],
          imageUrl: prodData['imageUrl'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
        ));
        _items = loadedProducts;
      });
      print(json.decode(response.body));
    } catch (e) {
      print(e);
      throw (e);
    }
    notifyListeners();
  }

  Future addProduct(Product product) async {
    final url = Uri.parse(
        'https://my-project-c0d2a-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'isFavorite': product.isFavorite,
            'creatorId': userId,
          }));
      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future updateProduct(String productId, Product newProduct) async {
    final prodIndex = _items.indexWhere((element) => element.id == productId);
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://my-project-c0d2a-default-rtdb.firebaseio.com/products/$productId.json?auth=$authToken');
      http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
          }));

      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future deleteProduct(String id) async {
    final url = Uri.parse(
        'https://my-project-c0d2a-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    final existingIndex = _items.indexWhere((element) => element.id == id);
    var existingProduct = _items[existingIndex];
    _items.removeAt(existingIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingIndex, existingProduct);
      notifyListeners();
      throw HttpsException('Can\'t delete data');
    }
  }
}
