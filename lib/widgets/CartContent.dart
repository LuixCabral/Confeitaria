import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_confeitaria/models/Products.dart';
import 'package:app_confeitaria/service/CartProvider.dart';

class CartContent extends StatefulWidget {
  const CartContent({super.key});

  @override
  State<CartContent> createState() => _CartContentState();
}

class _CartContentState extends State<CartContent> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _address = '';
  bool _isCashOnDelivery = true;

  Future<void> _saveOrder(List<CartItem> cartItems) async {
    // Implementar lógica de salvar pedido, se necessário
  }

  void _finalizePurchase(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      _saveOrder(cartProvider.cartItems);
      cartProvider.clearCart();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Compra finalizada com sucesso!")),
      );
      // Optionally, switch back to home tab
      // You can handle this in MainPage if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final cartItems = cartProvider.cartItems;
        print('CartContent rebuilt with ${cartItems.length} items');

        double total = cartItems.fold(0.0, (sum, item) {
          final price = double.parse(item.product.price.replaceAll('R\$', '').replaceAll(',', '.'));
          return sum + (price * item.quantity);
        });

        return cartItems.isEmpty
            ? const Center(child: Text("Seu carrinho está vazio"))
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
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                                    child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text("${item.product.price} x ${item.quantity}"),
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
                                  print('Decrease quantity for item at index $index: ${item.product.name}');
                                  cartProvider.updateQuantity(index, item.quantity - 1);
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(item.quantity.toString()),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                padding: const EdgeInsets.all(8.0),
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  print('Increase quantity for item at index $index: ${item.product.name}');
                                  cartProvider.updateQuantity(index, item.quantity + 1);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                padding: const EdgeInsets.all(8.0),
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  print('Remove item at index $index: ${item.product.name}');
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "R\$${total.toStringAsFixed(2).replaceAll('.', ',')}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Detalhes de Entrega",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Nome",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Por favor, insira seu nome";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _name = value!;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Endereço",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Por favor, insira seu endereço";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _address = value!;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Pagamento na Entrega"),
                          Switch(
                            value: _isCashOnDelivery,
                            onChanged: (value) {
                              setState(() {
                                _isCashOnDelivery = value;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _finalizePurchase(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text("Finalizar Compra"),
                      ),
                    ],
                  ),
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