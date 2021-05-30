import 'dart:convert';

import 'package:flutter/material.dart';

import 'product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  final List<Product> _loadedProducts = [
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

  List<Product> get items {
    return [..._loadedProducts];
  }

  List<Product> get favoriteItems {
    return _loadedProducts.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _loadedProducts.firstWhere((product) => product.id == id);
  }

  Future<void> addProduct(Product product) {
    final url = Uri.https(
      'shopping-application-a7da5-default-rtdb.firebaseio.com',
      '/products.json',
    );
    return http
        .post(
      url,
      body: json.encode(
        {
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'isFavorite': product.isFavorite,
        },
      ),
    )
        .then(
      (response) {
        final newProduct = Product(
          title: product.title,
          description: product.description,
          id: json.decode(response.body)['name'],
          imageUrl: product.imageUrl,
          price: product.price,
        );
        _loadedProducts.add(newProduct);
        notifyListeners();
      },
    ).catchError((error) {
      print(error);
      throw error;
    });
  }

  void updateProduct(String id, Product newProduct) {
    final prodIndex = _loadedProducts.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      _loadedProducts[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print("...");
    }
  }

  void deleteProduct(String id) {
    _loadedProducts.removeWhere((element) => element.id == id);
    notifyListeners();
  }
}
