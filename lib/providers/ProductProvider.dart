import 'package:flutter/cupertino.dart';

import '../models/Products.dart';
import '../service/ApiService.dart';

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
      print('Produtos carregados: ${_products.length} itens'); // Depuração
      for (var product in _products) {
        print('Produto: ${product.name}, Categoria: ${product.category}'); // Depuração
      }
    } catch (e) {
      _error = e.toString();
      print('Erro ao carregar produtos: $e'); // Depuração
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}