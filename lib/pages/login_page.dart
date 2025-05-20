import 'package:app_confeitaria/responsive/desktop_body.dart';
import 'package:app_confeitaria/responsive/mobile_body.dart';
import 'package:app_confeitaria/responsive/responsive_layout.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(mobileBody: LoginMobileBody(), desktopBody: LoginDesktopBody()),
    );
  }
}