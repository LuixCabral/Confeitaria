import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/Products.dart';

class ApiService {
  static const String baseUrl = 'https://patisserieapi-production.up.railway.app/api';
  static const String productsEndpoint = '/product/list';
  static const String addressEndpoint = '/order/address/';
  static const String ordersEndpoint = '/order/create';

  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl$productsEndpoint'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar produtos: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> fetchAddress(String cep) async {
    final response = await http.get(Uri.parse('$baseUrl$addressEndpoint$cep'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Falha ao carregar dados do CEP: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    final response = await http.post(
      Uri.parse('$baseUrl$ordersEndpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(orderData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print(json.decode(response.body));
      return json.decode(response.body); // Retorna o JSON da resposta
    } else {
      throw Exception('Falha ao criar pedido: ${response.statusCode} - ${response.body}');
    }
  }
}