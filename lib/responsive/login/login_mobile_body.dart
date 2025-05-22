import 'package:flutter/material.dart';
import 'my_form.dart';
class LoginMobileBody extends StatefulWidget {
  const LoginMobileBody({super.key});

  @override
  State<LoginMobileBody> createState() => _LoginMobileBodyState();
}

class _LoginMobileBodyState extends State<LoginMobileBody> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent,
      body: MyForm(),
    );
  }
}