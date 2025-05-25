// lib/providers/product_provider.dart
import 'package:flutter/foundation.dart';
import 'package:app_confeitaria/service/ApiService.dart';
import 'package:app_confeitaria/models/Products.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await ApiService.fetchProducts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}