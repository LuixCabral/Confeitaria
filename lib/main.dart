import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_confeitaria/pages/CheckoutPage.dart';
import 'package:app_confeitaria/pages/login_mobile_body.dart';
import 'package:app_confeitaria/service/CartProvider.dart';
import 'package:app_confeitaria/providers/ProductProvider.dart';
import 'package:app_confeitaria/widgets/auth_wrapper.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => ProductProvider()),
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
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginMobileBody(),
        '/checkout': (context) => const CheckoutPage(),
      },
    );
  }
}