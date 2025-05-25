import 'package:flutter/material.dart';

class OrderStatusPage extends StatelessWidget {
  const OrderStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final orderPlacedDate = DateTime(2025, 5, 24, 9, 27); // Example date from image
    final orderProcessedDate = now; // Current date and time

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Text(
                    "Status do Pedido",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 48), // Placeholder to balance layout
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Acompanhar Pedido",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "SN-3836",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.green,
                          child: Icon(Icons.check, size: 16, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Pedido realizado e confirmado",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "${orderPlacedDate.hour}:${orderPlacedDate.minute} - ${orderPlacedDate.day}/${orderPlacedDate.month}/${orderPlacedDate.year}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.yellow,
                          ),
                          child: const Icon(Icons.local_dining, size: 16, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Pedido em preparo",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "${orderProcessedDate.hour}:${orderProcessedDate.minute} - ${orderProcessedDate.day}/${orderProcessedDate.month}/${orderProcessedDate.year}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.local_shipping, size: 16, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Pedido em entrega",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "em breve",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12.0),
              ),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Implement WhatsApp tracking logic here (e.g., open WhatsApp with order details)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Acompanhar no WhatsApp (funcionalidade a implementar)")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Acompanhe seu pedido no WhatsApp",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}