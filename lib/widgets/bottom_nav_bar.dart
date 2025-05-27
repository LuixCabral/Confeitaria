import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../providers/cart_provider.dart'; // Adjust the import path as needed

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabTapped;
  final int cartItemCount;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
    this.cartItemCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: CurvedNavigationBar(
        index: currentIndex,
        backgroundColor: Colors.white, // Matches MainPage background
        color: Colors.pink[50]!, // Soft pink for the bar
        buttonBackgroundColor: Colors.pink, // Bright pink for selected item
        animationDuration: const Duration(milliseconds: 400),
        animationCurve: Curves.easeInOut,
        height: 65, // Slightly taller for labels
        items: [
          _buildNavItem(
            icon: Icons.home,
            label: 'Início',
            isSelected: currentIndex == 0,
          ),
          _buildNavItem(
            icon: Icons.shopping_cart,
            label: 'Carrinho',
            isSelected: currentIndex == 1,
            badgeCount: cartItemCount,
          ),
          _buildNavItem(
            icon: Icons.delivery_dining,
            label: 'Pedidos',
            isSelected: currentIndex == 2,
          ),
          _buildNavItem(
            icon: Icons.person,
            label: 'Perfil',
            isSelected: currentIndex == 3,
          ),
        ],
        onTap: onTabTapped,
        letIndexChange: (index) => true,
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    int badgeCount = 0,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      // Adicionado para melhor centralização do conteúdo
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center, // Alterado para center
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28, // Reduzido de 30 (experimente 26 ou 28)
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(height: 2), // Reduzido de 4 (experimente 1, 2 ou 3)
            Text(
              label,
              style: TextStyle(
                fontSize: 10, // Reduzido de 12 (experimente 10 ou 11)
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
              // Garante que o texto esteja centralizado
              maxLines: 1,
              // Evita quebra de linha se o texto for muito longo
              overflow: TextOverflow
                  .ellipsis, // Adiciona "..." se o texto ainda for muito longo
            ),
          ],
        ),
        if (badgeCount > 0)
          Positioned(
            right: -8, // Ajustado ligeiramente (era -10)
            top: -8, // Ajustado ligeiramente (era -10)
            child: Container(
              padding: const EdgeInsets.all(4),
              // Levemente ajustado (era 5)
              decoration: BoxDecoration(
                color: Colors.red[400],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              // Levemente ajustado (era 22)
              child: Text(
                '$badgeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10, // Levemente ajustado (era 12)
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}