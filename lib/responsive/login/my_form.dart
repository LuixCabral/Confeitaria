import 'package:app_confeitaria/pages/MainPage.dart'; // Import the HomePage (adjust the path if needed)
import 'package:flutter/material.dart';

class MyForm extends StatefulWidget {
  const MyForm({super.key});

  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final emaileditor = TextEditingController();
  final passwordEditor = TextEditingController();
  bool _rememberMe = false;

  void _toggleRememberMe(bool? value) {
    setState(() {
      _rememberMe = value ?? false;
    });
  }

  @override
  void dispose() {
    emaileditor.dispose();
    passwordEditor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 500,
                  width: 375,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      const Text(
                        'Bem Vindo!!',
                        style: TextStyle(
                          color: Colors.deepPurpleAccent,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 3.0,
                          horizontal: 25.0,
                        ),
                        child: TextField(
                          controller: emaileditor,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 3.0,
                          horizontal: 25.0,
                        ),
                        child: TextField(
                          controller: passwordEditor,
                          decoration: const InputDecoration(
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
                            padding: const EdgeInsets.only(left: 25.0),
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: _toggleRememberMe,
                            ),
                          ),
                          const Text('Lembrar-me'),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: 150,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {
                            if (emaileditor.text.isEmpty || passwordEditor.text.isEmpty) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Erro'),
                                  content: const Text(
                                    'Por favor, preencha o email e a senha.',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              // Navigate to HomePage
                              Navigator.pushReplacement(
                                context,
                                  MaterialPageRoute(builder: (context) => const MainPage()),
                              );
                            }
                          },
                          style: ButtonStyle(
                            shadowColor: WidgetStateProperty.all(Colors.deepPurple),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          child: const Text(
                            'login',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
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
