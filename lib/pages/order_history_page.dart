import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_confeitaria/localdata/database_helper.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState(); // Changed to State
}

class _OrderHistoryPageState extends State<OrderHistoryPage> { // Changed to State
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 1)); // Simulate loading
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        title: const Text(
          'História de Pedidos',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.pink))
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: DatabaseHelper.instance.getOrders(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.pink));
              }
              final orders = snapshot.data!;
              if (orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.history,
                        size: 100,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Nenhum pedido realizado',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Faça um pedido para começar!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return FutureBuilder<List<Map<String, dynamic>>>(
                    future: DatabaseHelper.instance.getOrderItems(order['id']),
                    builder: (context, itemsSnapshot) {
                      if (!itemsSnapshot.hasData) {
                        return const SizedBox.shrink();
                      }
                      final orderItems = itemsSnapshot.data!;
                      String formattedDate = 'Data inválida';
                      try {
                        final DateTime dateTime = DateTime.parse(order['dateTime']).toLocal();
                        formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
                      } catch (e) {
                        print('Error parsing date: $e'); // Changed print message for clarity
                      }
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                        shape: RoundedRectangleBorder( // Corrected syntax for shape
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.white, // Added color property for Card
                        child: ExpansionTile(
                          leading: const Icon(Icons.receipt, color: Colors.pink),
                          title: Text(
                            'Pedido ${order['orderNumber']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            'Data: $formattedDate\nTotal: R\$${order['total'].toStringAsFixed(2).replaceAll('.', ',')}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow('Cliente', order['name']),
                                  _buildInfoRow('Status', order['status']),
                                  _buildInfoRow('Endereço', order['address']),
                                  _buildInfoRow('Código', order['orderCode']),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Itens',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...orderItems.map((item) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${item['name']} (x${item['quantity']})',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'R\$${(item['price'] * item['quantity']).toStringAsFixed(2).replaceAll('.', ',')}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.pink,
                                          ),
                                        ),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}