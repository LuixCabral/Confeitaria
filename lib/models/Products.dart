// lib/models/product_model.dart
class Product {
  final int id;
  final String name;
  final String category;
  final double price;
  final String imagePath;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imagePath,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Produto Desconhecido',
      category: json['category'] as String? ?? 'Uncategorized',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imagePath: json['imagePath'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'imagePath': imagePath,
    };
  }
}
class OrderProduct {
  final int id;
  final String name;
  final double price;
  final String category;
  final String imagePath;
  final int quantity;

  OrderProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imagePath,
    required this.quantity,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      category: json['category'],
      imagePath: json['imagePath'],
      quantity: json['quantity'],
    );
  }
}
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  Map<String, dynamic> toJson() {
    return {
      'id': product.id, // Problema: o backend espera 'productId'
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product(
        id: json['id'] as int? ?? 0,
        name: 'Produto Desconhecido',
        price: 0.0,
        imagePath: '',
        category: 'Uncategorized',
      ),
      quantity: json['quantity'] as int? ?? 1,
    );
  }

}