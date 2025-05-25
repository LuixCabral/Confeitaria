import 'package:app_confeitaria/service/CartProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_confeitaria/models/Products.dart';
import 'package:app_confeitaria/providers/ProductProvider.dart';
import 'package:app_confeitaria/widgets/bottom_nav_bar.dart';
import 'package:app_confeitaria/widgets/CartContent.dart';
import 'package:app_confeitaria/widgets/OrderStatus.dart';
import 'package:app_confeitaria/widgets/ProfilePage.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  String _selectedCategory = "Cakes";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<ProductProvider>(context, listen: false).fetchProducts();
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
    String displayName;
    switch (category) {
      case "Cakes":
        displayName = "Bolos";
        break;
      case "Pies":
        displayName = "Tortas";
        break;
      case "Sweets":
        displayName = "Doces";
        break;
      case "Drinks":
        displayName = "Bebidas";
        break;
      default:
        displayName = category;
    }

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
      child: Text(displayName),
    )
        : OutlinedButton(
      onPressed: () => _onCategoryTapped(category),
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(displayName),

    );
  }

  Widget _buildHomeContent() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (productProvider.error != null) {
          return Center(child: Text('Erro: ${productProvider.error}'));
        }

        final filteredProducts = productProvider.products
            .where((product) => product.category == _selectedCategory)
            .toList();

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
              child: SizedBox(
                height: 50, // Define a altura fixa para os botões
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryButton("Cakes"),
                      const SizedBox(width: 8.0),
                      _buildCategoryButton("Pies"),
                      const SizedBox(width: 8.0),
                      _buildCategoryButton("Sweets"),
                      const SizedBox(width: 8.0),
                      _buildCategoryButton("Drinks"),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: filteredProducts.isEmpty
                    ? const Center(child: Text("Nenhum produto nesta categoria"))
                    : GridView.builder(
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
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
                                  'R\$${product.price.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    onPressed: () => Provider.of<CartProvider>(
                                        context,
                                        listen: false)
                                        .addToCart(product),
                                    icon: const Icon(
                                        Icons.shopping_bag_outlined,
                                        color: Colors.pink),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeContent(),
            CartContent(onAddMoreProducts: () => setState(() => _currentIndex = 0)),
            const OrderStatusPage(),
            const ProfileScreen(),
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