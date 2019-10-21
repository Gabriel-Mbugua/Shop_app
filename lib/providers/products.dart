import 'dart:ui';

import 'package:flutter/material.dart';
import 'product.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

//  var _showFavouritesOnly = false;

  List<Product> get items {
//    if(_showFavouritesOnly == true) {
//      return _items.where((prodItem) => prodItem.isFavourite).toList();
//    }
    return [..._items]; //Returns a copy of the _items list
  }

  List<Product> get favouriteItems {
    return _items.where((prodItem) => prodItem.isFavourite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

//  void showFavouritesOnly(){
//    _showFavouritesOnly = true;
//    notifyListeners();
//  }
//
//  void showAll(){
//    _showFavouritesOnly = false;
//    notifyListeners();
//  }

  Future<void> fetchAndSetProducts() async {
    const url = "https://shopapp-bd87e.firebaseio.com/products.json";

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      if (extractedData == null) {
        return;
      }
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(
          Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            isFavourite: prodData['isFavourite'],
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    const url = "https://shopapp-bd87e.firebaseio.com/products.json";

    try {
      final response = await http.post(
        url,
        body: json.encode({
          "title": product.title,
          "price": product.price,
          "description": product.description,
          "imageUrl": product.imageUrl,
          "isFavourite": product.isFavourite,
        }),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)["name"],
      );
      _items.add(newProduct);
    } catch (error) {
      print(error);
      throw error;
    }
    // _items.insert(0, newProduct); adds item to the beginning of the list
    notifyListeners();
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final url = "https://shopapp-bd87e.firebaseio.com/products/$id.json";

    try {
      await http.patch(url, //patch merges
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
          }));
    } catch (error) {
      throw error;
    }

    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = "https://shopapp-bd87e.firebaseio.com/products/$id.json";
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    notifyListeners();
    // _items.removeWhere((prod) => prod.id == id);

    _items.removeAt(
        existingProductIndex); //removes the item from the list but not from memory
    notifyListeners();

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex,
          existingProduct); //If deleting failed, the product will be reinserted
      notifyListeners();
      throw HttpException("Could not delete product");
    }
    //If item deletion successful, no need to keep it in memory
    existingProduct = null;
  }
}