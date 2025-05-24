import 'package:app_confeitaria/pages/cart_page.dart';
import 'package:app_confeitaria/service/CartProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_confeitaria/pages/MainPage.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Confeitaria App',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const MainPage(),
      routes: {
        '/cart': (context) => const CartPage(),
      },
    );
  }
}