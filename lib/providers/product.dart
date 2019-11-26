import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavourite = false,
  });

  void _setFavValue(bool newValue) {
    //rollback in case of error
    isFavourite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavouriteStatus(String token, String userId) async {
    //store the old status incase we run into an error and need to rollback
    final oldStatus = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();
    //update the favourite status of an existing product
    final url =
        "https://shopapp-bd87e.firebaseio.com/userFavourites/$userId/$id.json?auth=$token";
    try {
      final response = await http.put(
        url,
        body: json.encode(
          isFavourite,
        ),
      );
      if (response.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (error) {
      _setFavValue(oldStatus);
    }
  }
}
