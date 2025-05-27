import 'package:app_confeitaria/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_confeitaria/providers/product_provider.dart';
import 'package:app_confeitaria/widgets/bottom_nav_bar.dart';
import 'package:app_confeitaria/pages/cart_content_page.dart';
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
  String _selectedCategory = "All";
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

  void _navigateToHome() {
    setState(() {
      _currentIndex = 0;
      // Clear order state to prevent stale data
      _orderStatus = 'nenhum';
      _orderCode = '';
      _name = '';
      _orderDate = '';
      _products = [];
      _totalPrice = 0.0;
      // Optionally clear cart
      Provider.of<CartProvider>(context, listen: false).clearCart();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasFetchedProducts) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts().then((_) {
        setState(() {
          _hasFetchedProducts = true;
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar produtos: $error'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
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
    IconData? icon;
    switch (category) {
      case "All":
        displayName = "Todos";
        icon = Icons.all_inclusive;
        break;
      case "Cakes":
        displayName = "Bolos";
        icon = Icons.cake;
        break;
      case "Pies":
        displayName = "Tortas";
        icon = Icons.pie_chart;
        break;
      case "Sweets":
        displayName = "Doces";
        icon = Icons.cookie;
        break;
      case "Drinks":
        displayName = "Bebidas";
        icon = Icons.local_drink;
        break;
      default:
        displayName = category;
        icon = Icons.category;
    }

    bool isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton.icon(
        onPressed: () => _onCategoryTapped(category),
        icon: Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.pink),
        label: Text(displayName),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.pink : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.pink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          elevation: isSelected ? 4 : 0,
          shadowColor: Colors.black26,
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: Colors.pink));
        }
        if (productProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text(
                  'Erro: ${productProvider.error}',
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
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
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.pink, Color(0xFFD1A78A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.location_on, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Teresina, PI",
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Oficina do Bolo",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Procurar produtos...",
                      hintStyle: const TextStyle(color: Colors.grey),
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
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.pink, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: SizedBox(
                height: 48,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryButton("All"),
                      _buildCategoryButton("Cakes"),
                      _buildCategoryButton("Pies"),
                      _buildCategoryButton("Sweets"),
                      _buildCategoryButton("Drinks"),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: filteredProducts.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.search_off,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? "Nenhum produto nesta categoria"
                            : "Nenhum produto encontrado",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
                    : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProductDetailsPage(),
                            settings: RouteSettings(arguments: product),
                          ),
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Hero(
                                tag: 'product-${product.id}',
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
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
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'R\$${product.price.toStringAsFixed(2).replaceAll('.', ',')}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      onPressed: () {
                                        Provider.of<CartProvider>(context, listen: false)
                                            .addToCart(product, 1);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('${product.name} adicionado ao carrinho!'),
                                            backgroundColor: Colors.pink,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.add_shopping_cart,
                                        color: Colors.pink,
                                        size: 22,
                                      ),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.pink.withOpacity(0.1),
                                        padding: const EdgeInsets.all(8),
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
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeContent(),
            CartContent(
              onAddMoreProducts: _navigateToHome,
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
                address: '',
                onNavigateToHome: _navigateToHome,
              ),
            ),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final cartItemCount = cartProvider.cartItems.fold<int>(
            0,
                (sum, item) => sum + item.quantity,
          );
          return BottomNavBar(
            currentIndex: _currentIndex,
            onTabTapped: _onTabTapped,
            cartItemCount: cartItemCount,
          );
        },
      ),
    );
  }
}