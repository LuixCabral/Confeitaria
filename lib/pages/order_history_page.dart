import 'package:app_confeitaria/localdata/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 1)); // Simula carregamento
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Histórico de Pedidos"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: DatabaseHelper.instance.getOrders(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final orders = snapshot.data!;
              if (orders.isEmpty) {
                return const Center(child: Text("Nenhum pedido realizado"));
              }
              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return FutureBuilder<List<Map<String, dynamic>>>(
                    future: DatabaseHelper.instance.getOrderItems(order['id']),
                    builder: (context, itemsSnapshot) {
                      if (!itemsSnapshot.hasData) {
                        return const SizedBox.shrink(); // Ou um placeholder
                      }
                      final orderItems = itemsSnapshot.data!;
                      // Format date with error handling
                      String formattedDate = 'Data inválida';
                      try {
                        final DateTime dateTime = DateTime.parse(order['dateTime']).toLocal();
                        formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
                      } catch (e) {
                        print('Error parsing date for order ${order['orderCode']}: $e');
                      }
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ExpansionTile(
                          title: Text("Pedido ${order['orderNumber']} (Código: ${order['orderCode']})"),
                          subtitle: Text(
                            "Data: $formattedDate\nTotal: R\$${order['total'].toStringAsFixed(2).replaceAll('.', ',')}",
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Cliente: ${order['name']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text("Status: ${order['status']}", style: const TextStyle(fontStyle: FontStyle.italic)),
                                  Text("Endereço: ${order['address']}"),
                                  const SizedBox(height: 8),
                                  const Text("Itens:", style: TextStyle(fontWeight: FontWeight.bold)),
                                  ...orderItems.map((item) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: Text("${item['name']} (x${item['quantity']})")),
                                        Text("R\$${(item['price'] * item['quantity']).toStringAsFixed(2).replaceAll('.', ',')}"),
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}