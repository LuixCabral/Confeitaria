import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_confeitaria/pages/MainPage.dart';
import 'package:app_confeitaria/pages/CheckoutPage.dart';
import 'package:app_confeitaria/service/CartProvider.dart';
import 'package:app_confeitaria/providers/ProductProvider.dart'; // Import ProductProvider

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => ProductProvider()), // Add ProductProvider
      ],
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
        '/checkout': (context) => const CheckoutPage(),
      },
    );
  }
}