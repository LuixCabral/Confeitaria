import 'package:app_confeitaria/pages/main_page.dart';
import 'package:app_confeitaria/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginMobileBody extends StatefulWidget {
  const LoginMobileBody({super.key});

  @override
  State<LoginMobileBody> createState() => _LoginMobileBodyState();
}

class _LoginMobileBodyState extends State<LoginMobileBody> {
  final phoneEditor = TextEditingController();
  final passwordEditor = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) # ####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState() {
    super.initState();
    _loadRememberMePreference();
  }

  Future<void> _loadRememberMePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('remember_me') ?? false;
    });
  }

  Future<void> _saveRememberMePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', _rememberMe);
  }

  void _toggleRememberMe(bool? value) {
    setState(() {
      _rememberMe = value ?? false;
    });
    _saveRememberMePreference();
  }

  Future<void> _handleLogin() async {
    if (phoneEditor.text.isEmpty || passwordEditor.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erro'),
          content: const Text(
            'Por favor, preencha o número de telefone e a senha.',
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
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final cleanPhone = phoneEditor.text.replaceAll(RegExp(r'[()\-\s]'), '');
      final success = await _authService.login(cleanPhone, passwordEditor.text);

      if (success) {
        final userName = await _authService.getUserName();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bem-vindo, ${userName ?? 'Usuário'}!')),
          );
          await _saveRememberMePreference();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Erro'),
            content: Text(
              e.toString().replaceFirst('Exception: ', ''),
              style: const TextStyle(color: Colors.red),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    phoneEditor.dispose();
    passwordEditor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtém as dimensões da tela
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFBF927B),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                // Ajusta a largura com base no tamanho da tela, com um máximo de 375
                width: screenWidth > 375 ? 375 : screenWidth * 0.9,
                // Remove a altura fixa para evitar overflow
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Ajusta o tamanho ao conteúdo
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      'Bem Vindo!!',
                      style: TextStyle(
                        color: Colors.pinkAccent,
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
                        controller: phoneEditor,
                        decoration: const InputDecoration(
                          labelText: 'Número de Telefone',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [_phoneMaskFormatter],
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
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith<Color>(
                                (states) {
                              if (states.contains(WidgetState.disabled)) {
                                return Colors.grey;
                              }
                              return Colors.pinkAccent;
                            },
                          ),
                          shadowColor: WidgetStateProperty.all(const Color(0xFFBF927B)),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                            : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16), // Espaço extra no final
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}