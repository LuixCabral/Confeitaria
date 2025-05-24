import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_confeitaria/models/Products.dart';
import 'package:app_confeitaria/service/CartProvider.dart';
import 'package:app_confeitaria/widgets/bottom_nav_bar.dart';
import 'package:app_confeitaria/widgets/CartContent.dart'; // Import the new CartContent widget

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  String _selectedCategory = "Bolos";

  final List<Product> _allProducts = const [
    Product(
      name: "Bolo Valdo",
      price: "R\$40,00",
      imagePath: "assets/images/bolo_valdo.jpg",
      category: "Bolos",
    ),
    Product(
      name: "Bolo de Cenoura",
      price: "R\$30,00",
      imagePath: "assets/images/bolo_cenoura.jpg",
      category: "Bolos",
    ),
    Product(
      name: "Red Velvet",
      price: "R\$45,00",
      imagePath: "assets/images/red_velvet.jpg",
      category: "Bolos",
    ),
    Product(
      name: "Torta Mineira",
      price: "R\$10,00",
      imagePath: "assets/images/torta_mineira.jpg",
      category: "Tortas",
    ),
    Product(
      name: "Torta de Creme",
      price: "R\$10,00",
      imagePath: "assets/images/torta_creme.jpg",
      category: "Tortas",
    ),
    Product(
      name: "Brownie",
      price: "R\$10,00",
      imagePath: "assets/images/brownie.jpg",
      category: "Doces",
    ),
    Product(
      name: "Brigadeiro",
      price: "R\$5,00",
      imagePath: "assets/images/brigadeiro.jpg",
      category: "Doces",
    ),
    Product(
      name: "Suco de Laranja",
      price: "R\$8,00",
      imagePath: "assets/images/suco_laranja.jpg",
      category: "Drinks",
    ),
    Product(
      name: "Refrigerante",
      price: "R\$6,00",
      imagePath: "assets/images/refrigerante.jpg",
      category: "Drinks",
    ),
  ];

  List<Product> get _filteredProducts {
    return _allProducts.where((product) => product.category == _selectedCategory).toList();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onCategoryTapped(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  Widget _buildCategoryButton(String category) {
    bool isSelected = _selectedCategory == category;
    return isSelected
        ? ElevatedButton(
      onPressed: () => _onCategoryTapped(category),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(category),
    )
        : OutlinedButton(
      onPressed: () => _onCategoryTapped(category),
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(category),
    );
  }

  Widget _buildHomeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.location_on, color: Colors.pink),
                  SizedBox(width: 4),
                  Text(
                    "Teresina, PI",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Bolos Frescos\ntodo dia",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: "Procurar",
                  prefixIcon: const Icon(Icons.search, color: Colors.pink),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCategoryButton("Bolos"),
              _buildCategoryButton("Tortas"),
              _buildCategoryButton("Doces"),
              _buildCategoryButton("Drinks"),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _filteredProducts.isEmpty
                ? const Center(child: Text("Nenhum produto nesta categoria"))
                : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          child: Image.asset(
                            product.imagePath,
                            fit: BoxFit.cover,
                            width: double.infinity,
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
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              product.price,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                onPressed: () => Provider.of<CartProvider>(context, listen: false).addToCart(product),
                                icon: const Icon(Icons.shopping_bag_outlined, color: Colors.pink),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeContent(), // Home tab content
            const CartContent(),  // Cart tab content
            const Center(child: Text("Delivery Page")), // Placeholder for delivery tab
            const Center(child: Text("Profile Page")), // Placeholder for profile tab
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }
}