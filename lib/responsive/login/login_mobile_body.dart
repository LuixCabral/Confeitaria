import 'package:flutter/material.dart';

class LoginMobileBody extends StatefulWidget {
  const LoginMobileBody({super.key});

  @override
  State<LoginMobileBody> createState() => _LoginMobileBodyState();
}

class _LoginMobileBodyState extends State<LoginMobileBody> {
  bool _rememberMe = false;

  void _toggleRememberMe(bool? value) {
    setState(() {
      _rememberMe = value ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  height: 550,
                  width: 350,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // O texto "Login" fica próximo ao topo da caixa
                      const SizedBox(height: 24),
                      const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Adicione outros widgets aqui se necessário
                      const SizedBox(height: 32),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 25.0),
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 3.0, horizontal:25.0),
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 25.0),
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: _toggleRememberMe,
                            ),
                          ),
                          const Text('Lembrar-me'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}