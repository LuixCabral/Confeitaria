// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_confeitaria/models/Products.dart';

class ApiService {
  static const String baseUrl = 'https://patisserieapi-production.up.railway.app/api';
  static const String productsEndpoint = '/product/list';

  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl$productsEndpoint'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar produtos: ${response.statusCode}');
    }

  }

  // Placeholder para outros endpoints futuros
  static Future<dynamic> fetchUsers() async {
    // Implementar quando necessário
    throw UnimplementedError();
  }

  static Future<dynamic> fetchOrders() async {
    // Implementar quando necessário
    throw UnimplementedError();
  }
}