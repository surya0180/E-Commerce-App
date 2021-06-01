import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/models/http_exception.dart';

import 'product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _loadedProducts = [];

  List<Product> get items {
    return [..._loadedProducts];
  }

  List<Product> get favoriteItems {
    return _loadedProducts.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _loadedProducts.firstWhere((product) => product.id == id);
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.https(
      'shopping-application-a7da5-default-rtdb.firebaseio.com',
      '/products.json',
    );

    try {
      final response = await http.post(
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
      );

      final newProduct = Product(
        title: product.title,
        description: product.description,
        id: json.decode(response.body)['name'],
        imageUrl: product.imageUrl,
        price: product.price,
      );

      _loadedProducts.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _loadedProducts.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      final url = Uri.https(
        'shopping-application-a7da5-default-rtdb.firebaseio.com',
        '/products/$id.json',
      );
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      _loadedProducts[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print("...");
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.https(
      'shopping-application-a7da5-default-rtdb.firebaseio.com',
      '/products/$id.json',
    );

    final existingProductIndex =
        _loadedProducts.indexWhere((element) => element.id == id);

    var existingProduct = _loadedProducts[existingProductIndex];

    _loadedProducts.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _loadedProducts.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete the product.');
    }

    existingProduct = null;
  }

  Future<void> fetchAndSetProducts() async {
    final url = Uri.https(
      'shopping-application-a7da5-default-rtdb.firebaseio.com',
      '/products.json',
    );
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> tempList = [];
      extractedData.forEach((prodId, prodData) {
        tempList.add(
          Product(
            id: prodId,
            description: prodData['description'],
            imageUrl: prodData['imageUrl'],
            price: prodData['price'],
            title: prodData['title'],
            isFavorite: prodData['isFavorite'],
          ),
        );
      });
      _loadedProducts = tempList;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }
}
