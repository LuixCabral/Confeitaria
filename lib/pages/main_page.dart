import 'package:app_confeitaria/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_confeitaria/models/products.dart';
import 'package:app_confeitaria/providers/product_provider.dart';
import 'package:app_confeitaria/widgets/bottom_nav_bar.dart';
import 'package:app_confeitaria/widgets/cart_content.dart';
import 'package:app_confeitaria/pages/order_status_page.dart';
import 'package:app_confeitaria/pages/profile_page.dart';
import 'package:app_confeitaria/pages/product_details_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  String _selectedCategory = "All"; // Default to "All" for all products
  String _orderStatus = 'nenhum';
  String _orderCode = '';
  String _name = '';
  String _orderDate = '';
  List<Map<String, dynamic>> _products = [];
  double _totalPrice = 0.0;
  bool _hasFetchedProducts = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  void _updateOrderStatus({
    required String name,
    required String status,
    required String code,
    required String date,
    required List<Map<String, dynamic>> products,
    required double totalPrice,
    String address = '',
  }) {
    setState(() {
      _name = name;
      _orderStatus = status;
      _orderCode = code;
      _orderDate = DateTime.parse(date).toIso8601String();
      _products = products;
      _totalPrice = totalPrice;
      _currentIndex = 2;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasFetchedProducts) {
      Provider.of<ProductProvider>(context, listen: false)
          .fetchProducts()
          .then((_) {
        setState(() {
          _hasFetchedProducts = true;
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar produtos: $error')),
        );
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
  }

  Widget _buildCategoryButton(String category) {
    String displayName;
    switch (category) {
      case "All":
        displayName = "Todos";
        break;
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

        final filteredProducts = productProvider.products.where((product) {
          final matchesCategory = _selectedCategory == "All" ||
              product.category.toLowerCase() == _selectedCategory.toLowerCase();
          final matchesSearch = _searchQuery.isEmpty ||
              product.name.toLowerCase().contains(_searchQuery.toLowerCase());
          return matchesCategory && matchesSearch;
        }).toList();

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
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Procurar",
                      prefixIcon: const Icon(Icons.search, color: Colors.pink),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.pink),
                        onPressed: _clearSearch,
                      )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: SizedBox(
                height: 50,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryButton("All"), // New: All Products
                      const SizedBox(width: 8.0),
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
                    ? const Center(child: Text("Nenhum produto encontrado"))
                    : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsPage(),
                            settings: RouteSettings(arguments: product),
                          ),
                        );
                      },
                      child: Card(
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
                                      onPressed: () {
                                        Provider.of<CartProvider>(context, listen: false)
                                            .addToCart(product, 1);
                                        print(
                                            'Produto adicionado ao carrinho: ${product.name} (ID: ${product.id})');
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                '${product.name} adicionado ao carrinho!'),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.shopping_bag_outlined,
                                        color: Colors.pink,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
            CartContent(
              onAddMoreProducts: () => setState(() => _currentIndex = 0),
              updateOrderStatus: _updateOrderStatus,
            ),
            KeyedSubtree(
              key: ValueKey('$_orderStatus-$_orderCode'),
              child: OrderStatusPage(
                name: _name,
                orderStatus: _orderStatus,
                orderCode: _orderCode,
                orderDate: _orderDate,
                products: _products,
                totalPrice: _totalPrice,
              ),
            ),
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