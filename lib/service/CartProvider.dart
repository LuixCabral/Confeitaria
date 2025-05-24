import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:app_confeitaria/models/Products.dart';
class CartProvider extends ChangeNotifier {
  List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  CartProvider() {
    _loadCart();
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getStringList('cart') ?? [];
    _cartItems = cartJson.map((json) => CartItem.fromJson(jsonDecode(json))).toList();
    notifyListeners();
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = _cartItems.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('cart', cartJson);
  }

  Future<void> addToCart(Product product) async {
    final existingItem = _cartItems.firstWhere(
          (item) => item.product.name == product.name,
      orElse: () => CartItem(product: product, quantity: 0),
    );
    if (_cartItems.contains(existingItem)) {
      existingItem.quantity += 1;
    } else {
      _cartItems.add(CartItem(product: product, quantity: 1));
    }
    await _saveCart();
    notifyListeners();
  }

  Future<void> removeFromCart(int index) async {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
      await _saveCart();
      notifyListeners();
    }
  }

  Future<void> updateQuantity(int index, int newQuantity) async {
    if (index >= 0 && index < _cartItems.length) {
      if (newQuantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = newQuantity;
      }
      await _saveCart();
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _cartItems.clear();
    await _saveCart();
    notifyListeners();
  }
}