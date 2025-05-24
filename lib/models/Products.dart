class Product {
  final String name;
  final String price;
  final String imagePath;
  final String category;

  const Product({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.category,
  });
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
        name: json['product']['name'],
        price: json['product']['price'],
        imagePath: json['product']['imagePath'],
        category: json['product']['category'],
      ),
      quantity: json['quantity'],
    );
  }
}