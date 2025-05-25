import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_confeitaria/service/CartProvider.dart';

class CartContent extends StatelessWidget {
  final VoidCallback onAddMoreProducts;

  const CartContent({super.key, required this.onAddMoreProducts});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final cartItems = cartProvider.cartItems;
        print('CartContent rebuilt with ${cartItems.length} items');

        // Calcula o total diretamente com price como double
        double total = cartItems.fold(0.0, (sum, item) {
          return sum + (item.product.price * item.quantity);
        });

        return cartItems.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                "Seu carrinho está vazio",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onAddMoreProducts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Adicionar Produtos"),
              ),
            ],
          ),
        )
            : SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              item.product.imagePath,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "R\$${item.product.price.toStringAsFixed(2).replaceAll('.', ',')} x ${item.quantity}",
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                padding: const EdgeInsets.all(8.0),
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  print(
                                      'Decrease quantity for item at index $index: ${item.product.name}');
                                  cartProvider.updateQuantity(
                                      index, item.quantity - 1);
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0),
                                child: Text(item.quantity.toString()),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                padding: const EdgeInsets.all(8.0),
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  print(
                                      'Increase quantity for item at index $index: ${item.product.name}');
                                  cartProvider.updateQuantity(
                                      index, item.quantity + 1);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                padding: const EdgeInsets.all(8.0),
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  print(
                                      'Remove item at index $index: ${item.product.name}');
                                  cartProvider.removeFromCart(index);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total:",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "R\$${total.toStringAsFixed(2).replaceAll('.', ',')}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onAddMoreProducts,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Adicionar Mais Produtos"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: cartItems.isEmpty
                            ? null // Desativa o botão se o carrinho estiver vazio
                            : () {
                          Navigator.pushNamed(context, '/checkout');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Avançar"),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}