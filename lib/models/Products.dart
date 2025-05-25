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
      id: json['id'] as int? ?? 0, // Valor padrão se id estiver ausente
      name: json['name'] as String? ?? 'Produto Desconhecido', // Valor padrão
      category: json['category'] as String? ?? 'Uncategorized', // Valor padrão
      price: (json['price'] as num?)?.toDouble() ?? 0.0, // Converte num para double com valor padrão
      imagePath: json['imagePath'] as String? ?? '', // Valor padrão se ausente
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

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  Map<String, dynamic> toJson() {
    return {
      'product': {
        'name': product.name,
        'price': product.price,
        'imagePath': product.imagePath,
        'category': product.category,
      },
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product(
        id: 0, // ID não está no JSON do CartItem, pode ser ajustado no futuro
        name: json['product']['name'] as String? ?? 'Produto Desconhecido',
        price: (json['product']['price'] as num?)?.toDouble() ?? 0.0,
        imagePath: json['product']['imagePath'] as String? ?? '',
        category: json['product']['category'] as String? ?? 'Uncategorized',
      ),
      quantity: json['quantity'] as int? ?? 1,
    );
  }
}