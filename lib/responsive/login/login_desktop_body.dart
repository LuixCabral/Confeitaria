import 'package:flutter/material.dart';

class LoginDesktopBody extends StatelessWidget {
  const LoginDesktopBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.white,
      appBar: AppBar(
        title: const Text('Desktop'),
        centerTitle: true,
      ),
    );
  }
}