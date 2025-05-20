import 'package:flutter/material.dart';

class LoginMobileBody extends StatelessWidget {
  const LoginMobileBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.white,
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
    );
  }
}