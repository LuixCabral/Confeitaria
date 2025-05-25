import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderStatusPage extends StatefulWidget {
  final String name;
  final String orderCode;
  final String orderStatus;
  final String orderDate;
  final List<Map<String, dynamic>> products;
  final double totalPrice;

  const OrderStatusPage({
    super.key,
    required this.name,
    required this.orderCode,
    required this.orderStatus,
    required this.orderDate,
    required this.products,
    required this.totalPrice,
  });

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  late String _currentStatus;
  late Timer _statusTimer;

  @override
  void initState() {
    super.initState();
    // Validar o status inicial
    const List<String> statusSequence = [
      'enviado',
      'preparing',
      'saiu para entrega',
      'entregue'
    ];
    _currentStatus = widget.orderStatus.toLowerCase();

    // Se o status não estiver na sequência ou for 'nenhum', definir como 'enviado'
    if (_currentStatus == 'nenhum' || !statusSequence.contains(_currentStatus)) {
      _currentStatus = 'enviado'; // Valor padrão
    }

    if (_currentStatus != 'nenhum') {
      _startStatusSimulation();
    }
  }

  @override
  void dispose() {
    if (_currentStatus != 'nenhum') {
      _statusTimer.cancel();
    }
    super.dispose();
  }

  void _startStatusSimulation() {
    const List<String> statusSequence = [
      'enviado',
      'preparing',
      'saiu para entrega',
      'entregue'
    ];
    int currentIndex = statusSequence.indexOf(_currentStatus);

    _statusTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (currentIndex < statusSequence.length - 1) {
        setState(() {
          currentIndex++;
          _currentStatus = statusSequence[currentIndex];
        });
      } else {
        timer.cancel();
      }
    });
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'enviado':
        return Icons.send;
      case 'preparing':
        return Icons.kitchen;
      case 'saiu para entrega':
        return Icons.delivery_dining;
      case 'entregue':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'enviado':
        return Colors.blue;
      case 'preparing':
        return Colors.orange;
      case 'saiu para entrega':
        return Colors.purple;
      case 'entregue':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se não houver produtos ou o status for 'nenhum', mostrar mensagem de "Nenhum pedido ativo"
    if (widget.products.isEmpty || _currentStatus == 'nenhum') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.info_outline,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhum pedido ativo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    // Formatar a data para exibição
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final DateTime orderDateTime = DateTime.parse(widget.orderDate).toLocal();
    final String formattedDate = dateFormat.format(orderDateTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status do Pedido'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nome do Cliente
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.pink),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cliente: ${widget.name}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Código do Pedido
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.receipt, color: Colors.pink),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Código do Pedido: ${widget.orderCode}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Data do Pedido
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.pink),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Data do Pedido: $formattedDate',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status Atual com Ícone Animado
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      child: Icon(
                        _getStatusIcon(_currentStatus),
                        color: _getStatusColor(_currentStatus),
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status Atual:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _currentStatus.toUpperCase(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(_currentStatus),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Linha do Tempo do Status
            Expanded(
              child: ListView(
                children: [
                  _buildTimeline(),
                  const SizedBox(height: 16),
                  const Text(
                    'Itens do Pedido:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.products.length,
                    itemBuilder: (context, index) {
                      final product = widget.products[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
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
                                  product['imagePath'],
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
                                child: Text(
                                  "${product['name']} (x${product['quantity']})",
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                              Text(
                                'R\$${(product['price'] * product['quantity']).toStringAsFixed(2).replaceAll('.', ',')}',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'R\$${widget.totalPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Botão para Voltar à Loja
            if (_currentStatus == 'entregue')
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Voltar à Loja"),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    const List<String> statusSequence = [
      'enviado',
      'preparing',
      'saiu para entrega',
      'entregue'
    ];
    int currentIndex = statusSequence.indexOf(_currentStatus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(statusSequence.length, (index) {
        bool isCompleted = index <= currentIndex;
        bool isCurrent = index == currentIndex;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? Colors.pink : Colors.grey[300],
                    border: Border.all(
                      color: isCompleted ? Colors.pink : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  )
                      : null,
                ),
                if (index < statusSequence.length - 1)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 2,
                    height: 40,
                    color: isCompleted ? Colors.pink : Colors.grey[300],
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusSequence[index].toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isCompleted ? Colors.black : Colors.grey,
                      ),
                    ),
                    Text(
                      _getStatusDescription(statusSequence[index]),
                      style: TextStyle(
                        fontSize: 14,
                        color: isCompleted ? Colors.black54 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'enviado':
        return 'Seu pedido foi recebido com sucesso.';
      case 'preparing':
        return 'Estamos preparando seu pedido com carinho.';
      case 'saiu para entrega':
        return 'Seu pedido está a caminho!';
      case 'entregue':
        return 'Pedido entregue. Aproveite!';
      default:
        return '';
    }
  }
}