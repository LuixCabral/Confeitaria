import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../providers/cart_provider.dart'; // Adjust the import path as needed

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabTapped;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    final cartItems = Provider.of<CartProvider>(context).cartItems;

    return CurvedNavigationBar(
      index: currentIndex,
      backgroundColor: const Color(0xFFF5E8E4),
      color: const Color(0xFFBF927B),
      buttonBackgroundColor: Colors.white,
      animationDuration: const Duration(milliseconds: 300),
      items: [
        const Icon(Icons.home, size: 30, color: Colors.black54),
        Stack(
          children: [
            const Icon(Icons.shopping_cart, size: 30, color: Colors.black54),
            if (cartItems.isNotEmpty)
              Positioned(
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    cartItems.length.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const Icon(Icons.delivery_dining, size: 30, color: Colors.black54),
        const Icon(Icons.person, size: 30, color: Colors.black54),
      ],
      onTap: onTabTapped,
    );
  }
}