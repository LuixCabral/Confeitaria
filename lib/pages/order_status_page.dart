import 'dart:async';
import 'package:app_confeitaria/localdata/database_helper.dart'; // Verifique se este caminho está correto
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderStatusPage extends StatefulWidget {
  final String name;
  final String orderCode;
  final String orderStatus;
  final String orderDate;
  final List<Map<String, dynamic>> products;
  final double totalPrice;
  final String address;
  final VoidCallback onNavigateToHome;

  const OrderStatusPage({
    super.key,
    required this.name,
    required this.orderCode,
    required this.orderStatus,
    required this.orderDate,
    required this.products,
    required this.totalPrice,
    required this.address,
    required this.onNavigateToHome,
  });

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  late String _currentStatus;
  Timer? _statusTimer;
  final List<String> _statusSequence = const ['enviado', 'em preparo', 'saiu para entrega', 'entregue'];


  @override
  void initState() {
    super.initState();
    _currentStatus = widget.orderStatus.toLowerCase();

    // Ajusta o status inicial se necessário e se houver produtos
    if (widget.products.isNotEmpty) {
      if (_currentStatus == 'nenhum' || !_statusSequence.contains(_currentStatus)) {
        // Se o status for 'nenhum' ou inválido, mas temos produtos,
        // assume-se que o pedido acabou de ser feito e o status inicial é 'enviado'.
        _currentStatus = 'enviado';
      }
      // Inicia a simulação se o status atual não for 'entregue'
      // e se o status for um dos estágios válidos da sequência.
      if (_statusSequence.contains(_currentStatus) && _currentStatus != 'entregue') {
        _startStatusSimulation();
      }
    }
    // Se não houver produtos, a tela de "Nenhum pedido ativo" será mostrada.
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  void _startStatusSimulation() {
    // Não simula se não estiver montado, não houver produtos, ou se o status atual não estiver na sequência esperada.
    if (!mounted || widget.products.isEmpty || !_statusSequence.contains(_currentStatus)) return;

    int currentIndex = _statusSequence.indexOf(_currentStatus);

    // Não prossegue se o status atual for 'entregue' (último item da sequência) ou inválido.
    if (currentIndex < 0 || currentIndex >= _statusSequence.length - 1) {
      return;
    }

    final DatabaseHelper dbHelper = DatabaseHelper.instance;

    _statusTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // Avança para o próximo status na sequência
      if (currentIndex < _statusSequence.length - 1) {
        currentIndex++;
        if (mounted) {
          setState(() {
            _currentStatus = _statusSequence[currentIndex];
          });
        }

        // Tenta persistir a atualização do pedido no banco de dados.
        // IMPORTANTE: Se dbHelper.insertOrder sempre cria um NOVO registro,
        // isso pode não ser o ideal para ATUALIZAR um pedido existente.
        // Considere ter um método dbHelper.updateOrderStatus(orderCode, newStatus)
        // ou garantir que insertOrder faça um "upsert".
        try {
          List<Map<String, dynamic>> users = await dbHelper.getUser();
          int userId = users.isNotEmpty ? users[0]['id'] : 1; // Considere um fallback melhor

          final DateTime orderDateTime = DateTime.parse(widget.orderDate);
          final String isoDateTime = orderDateTime.toIso8601String(); // Data original do pedido

          await dbHelper.insertOrder(
            userId: userId,
            orderNumber: widget.orderCode, // Usado para identificar o pedido a ser atualizado/inserido
            orderCode: widget.orderCode,
            status: _currentStatus,
            dateTime: isoDateTime, // Ou DateTime.now().toIso8601String() para data da atualização do status
            address: widget.address,
            total: widget.totalPrice,
            name: widget.name,
            items: widget.products,
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao atualizar pedido no banco: $e'),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        }

        // Se o novo status for 'entregue', para o timer.
        if (_currentStatus == 'entregue') {
          timer.cancel();
        }
      } else {
        // Se já estiver no último status ou além, para o timer.
        timer.cancel();
      }
    });
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'enviado':
        return Icons.receipt_long_outlined;
      case 'em preparo':
        return Icons.soup_kitchen_outlined;
      case 'saiu para entrega':
        return Icons.local_shipping_outlined;
      case 'entregue':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'enviado':
        return Colors.blue.shade600;
      case 'em preparo':
        return Colors.orange.shade600;
      case 'saiu para entrega':
        return Colors.purple.shade600;
      case 'entregue':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    // Se não há produtos ou o status é 'nenhum' (e não foi ajustado no initState), mostra tela de nenhum pedido.
    if (widget.products.isEmpty || (_currentStatus == 'nenhum' && widget.orderStatus.toLowerCase() == 'nenhum')) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 100,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Nenhum pedido ativo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Faça um novo pedido agora!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: widget.onNavigateToHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.pink, Colors.pinkAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: const Text(
                      'Ir para a Loja',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final DateTime orderDateTime = DateTime.parse(widget.orderDate).toLocal();
    final String formattedDate = dateFormat.format(orderDateTime);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        title: const Text(
          'Status do Pedido',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: widget.onNavigateToHome,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              shadowColor: Colors.grey.withOpacity(0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.person_outline_rounded, 'Cliente', widget.name),
                    const Divider(height: 20, thickness: 0.5, color: Colors.grey),
                    _buildInfoRow(Icons.confirmation_number_outlined, 'Código', widget.orderCode),
                    const Divider(height: 20, thickness: 0.5, color: Colors.grey),
                    _buildInfoRow(Icons.calendar_today_outlined, 'Data', formattedDate),
                    if (widget.address.isNotEmpty) ...[
                      const Divider(height: 20, thickness: 0.5, color: Colors.grey),
                      _buildInfoRow(Icons.location_on_outlined, 'Endereço', widget.address),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 3,
              shadowColor: Colors.grey.withOpacity(0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getStatusColor(_currentStatus).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getStatusIcon(_currentStatus),
                        color: _getStatusColor(_currentStatus),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status Atual',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            _capitalize(_currentStatus),
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
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildTimeline(),
                  const SizedBox(height: 20),
                  const Text(
                    'Itens do Pedido',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.products.length,
                    itemBuilder: (context, index) {
                      final product = widget.products[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  product['imagePath'] ?? 'assets/images/placeholder.png',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[200],
                                      child: const Icon( // Correção aqui
                                        Icons.image_not_supported_outlined,
                                        color: Colors.grey,
                                        size: 30,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'] ?? 'Produto',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'x${product['quantity']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'R\$${(product['price'] * product['quantity']).toStringAsFixed(2).replaceAll('.', ',')}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.pink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    shadowColor: Colors.grey.withOpacity(0.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total do Pedido',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'R\$${widget.totalPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                            style: const TextStyle(
                              fontSize: 20, // Aumentado para destaque
                              fontWeight: FontWeight.bold,
                              color: Colors.pink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            if (_currentStatus == 'entregue')
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 16.0), // Padding inferior ajustado
                child: ElevatedButton(
                  onPressed: widget.onNavigateToHome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Consistente com outros botões
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.pink, Colors.pinkAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12), // Consistente
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: const Text(
                        'Voltar à Loja',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Melhor alinhamento para textos multilinhas
      children: [
        Icon(icon, color: Colors.pink.shade400, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle( // Ajustado para consistência
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey[700], // Um pouco mais escuro para contraste
                ),
              ),
              const SizedBox(height: 2), // Espaço entre label e value
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600, // Menos bold que o total
                  color: Colors.black87,
                ),
                softWrap: true, // Permite quebra de linha se o valor for longo
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    final int currentIndexInSequence = _statusSequence.indexOf(_currentStatus);

    return Card(
      elevation: 3,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(_statusSequence.length, (index) {
            final bool isCompleted = index <= currentIndexInSequence;
            final bool isCurrent = index == currentIndexInSequence;

            // Cores e pesos para os elementos da timeline
            Color circleColor = isCompleted ? Colors.pink : Colors.grey.shade200;
            Color borderColor = isCompleted ? Colors.pink : Colors.grey.shade400;
            Color lineColor = index < currentIndexInSequence ? Colors.pink : Colors.grey.shade200;
            Color titleColor = isCompleted ? Colors.black87 : Colors.grey.shade500;
            FontWeight titleWeight = isCurrent ? FontWeight.bold : FontWeight.w600;
            Color descriptionColor = isCompleted ? Colors.black54 : Colors.grey.shade400;


            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 30, // Correção: Removido width duplicado
                      height: 30, // Correção: Removido height duplicado
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: circleColor,
                        border: Border.all(
                          color: borderColor,
                          width: 2, // Correção: Removido width duplicado
                        ),
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Colors.white,
                        )
                            : isCurrent
                            ? Container( // Ponto para o status atual não concluído
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.pink.shade300,
                          ),
                        )
                            : null, // Nada para status futuros
                      ),
                    ),
                    if (index < _statusSequence.length - 1)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 2,  // Correção: Removido width duplicado
                        height: 50, // Correção: Removido height duplicado
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        color: lineColor,
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _capitalize(_statusSequence[index]),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: titleWeight,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getStatusDescription(_statusSequence[index]),
                          style: TextStyle(
                            fontSize: 13,
                            color: descriptionColor,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'enviado':
        return 'Confirmamos o seu pedido e ele já foi enviado para a cozinha.';
      case 'em preparo':
        return 'Nossos chefs estão preparando seu pedido com todo o carinho.';
      case 'saiu para entrega':
        return 'Seu pedido saiu e está a caminho. Prepare-se!';
      case 'entregue':
        return 'Seu pedido foi entregue! Esperamos que você aproveite!';
      default:
        return 'Aguardando informações sobre o pedido.'; // Adicionado um fallback
    }
  }
}