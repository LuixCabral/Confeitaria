class Product {
  final int id;
  final String name;
  final String category;
  final double price;
  final String imagePath;
  final String detalhes;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imagePath,
    required this.detalhes
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Produto Desconhecido',
      category: json['category'] as String? ?? 'Uncategorized',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imagePath: json['imagePath'] as String? ?? '',
      detalhes: json['description'] as String? ?? 'Sem Detalhes do Produto'
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
  final String description;

  OrderProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imagePath,
    required this.quantity,
    required this.description

  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      category: json['category'],
      imagePath: json['imagePath'],
      quantity: json['quantity'],
      description: json['description']
    );
  }
}