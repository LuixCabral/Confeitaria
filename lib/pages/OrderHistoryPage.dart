import 'package:app_confeitaria/localdata/DatabaseHelper.dart';
import 'package:flutter/material.dart';

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
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Text("Pedido ${order['orderNumber']}"),
                      subtitle: Text(
                        "Data: ${DateTime.parse(order['dateTime']).toLocal().toString().split('.')[0]}\nTotal: R\$${order['total'].toStringAsFixed(2).replaceAll('.', ',')}",
                      ),
                    ),
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