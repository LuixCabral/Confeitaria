import 'package:app_confeitaria/providers/cart_provider.dart';
import 'package:flutter/material.dart';

import '../models/products.dart';


class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  void addToCart(Product product, [int quantity = 1]) {
    final existingItemIndex = _cartItems.indexWhere((item) => item.product.id == product.id);

    if (existingItemIndex != -1) {
      // Se o produto já existe, incrementa a quantidade
      _cartItems[existingItemIndex] = CartItem(
        product: product,
        quantity: _cartItems[existingItemIndex].quantity + quantity,
      );
    } else {
      // Se não existe, adiciona um novo item com a quantidade especificada
      _cartItems.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void updateQuantity(int index, int newQuantity) {
    if (index < 0 || index >= _cartItems.length) {
      print('Invalid index: $index');
      return;
    }
    print('Updating quantity for ${ _cartItems[index].product.name} to $newQuantity');
    if (newQuantity <= 0) {
      _cartItems.removeAt(index);
    } else {
      _cartItems[index] = CartItem(
        product: _cartItems[index].product,
        quantity: newQuantity,
      );
    }
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _cartItems.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  double getTotal() {
    return _cartItems.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  Map<String, dynamic> toJson() {
    return {
      'productId': product.id,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product(
        id: json['productId'] as int? ?? 0,
        name: json['name'] as String? ?? 'Produto Desconhecido',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        imagePath: json['imagePath'] as String? ?? '',
        category: json['category'] as String? ?? 'Uncategorized', detalhes: '',
      ),
      quantity: json['quantity'] as int? ?? 1,
    );
  }
}