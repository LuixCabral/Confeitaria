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
      _showErrorDialog('Preencha o número de telefone e a senha.');
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
            SnackBar(
              content: Text('Bem-vindo, ${userName ?? 'Usuário'}!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
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
        _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Erro',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.red),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.pink)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    phoneEditor.dispose();
    passwordEditor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100], // Matches app theme
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white,
                child: Container(
                  width: screenWidth > 400 ? 400 : screenWidth * 0.9,
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Bem-vindo!',
                        style: TextStyle(
                          color: Colors.pink,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: phoneEditor,
                        decoration: InputDecoration(
                          labelText: 'Telefone',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          prefixIcon: const Icon(Icons.phone, color: Colors.pink),
                          labelStyle: const TextStyle(color: Colors.grey),
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [_phoneMaskFormatter],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordEditor,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          prefixIcon: const Icon(Icons.lock, color: Colors.pink),
                          labelStyle: const TextStyle(color: Colors.grey),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: _toggleRememberMe,
                            activeColor: Colors.pink,
                          ),
                          const Text(
                            'Lembrar-me',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                          disabledBackgroundColor: Colors.grey[300],
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: _isLoading
                                ? null
                                : const LinearGradient(
                              colors: [Colors.pink, Colors.pinkAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            color: _isLoading ? Colors.grey[300] : null,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            width: 200,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            alignment: Alignment.center,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                                : const Text(
                              'Entrar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}