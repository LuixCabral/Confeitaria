import 'package:app_confeitaria/pages/main_page.dart';
import 'package:app_confeitaria/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginMobileBody extends StatefulWidget {
  const LoginMobileBody({super.key});

  @override
  State<LoginMobileBody> createState() => _LoginMobileBodyState();
}

class _LoginMobileBodyState extends State<LoginMobileBody> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  final regPhoneController = TextEditingController();
  final regPasswordController = TextEditingController();

  bool _rememberMe = false;
  bool _isLoading = false;

  final _authService = AuthService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) # ####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState() {
    super.initState();
    _loadRememberMePreference();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  Future<void> _loadRememberMePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _rememberMe = prefs.getBool('remember_me') ?? false;
    setState(() {});
  }

  Future<void> _saveRememberMePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', _rememberMe);
  }

  void _toggleRememberMe(bool? value) {
    _rememberMe = value ?? false;
    _saveRememberMePreference();
    setState(() {});
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final cleanPhone = phoneController.text.replaceAll(RegExp(r'[()\-\s]'), '');

    try {
      final success = await _authService.login(cleanPhone, passwordController.text);
      if (success && mounted) {
        final userName = await _authService.getUserName();
        _showSnackBar('Bem-vindo, ${userName ?? 'Usuário'}!', Colors.green);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainPage()));
      }
    } catch (e) {
      _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCreateAccount() async {
    if (!_registerFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final cleanPhone = regPhoneController.text.replaceAll(RegExp(r'[()\-\s]'), '');

    try {
      final success = await _authService.createAccount(
        usernameController.text,
        cleanPhone,
        regPasswordController.text,
      );

      if (success && mounted) {
        final userName = await _authService.getUserName();
        _showSnackBar('Conta criada! Bem-vindo, ${userName ?? 'Usuário'}!', Colors.green);
        Navigator.pop(context);
        usernameController.clear();
        regPhoneController.clear();
        regPasswordController.clear();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainPage()));
      }
    } catch (e) {
      _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Erro', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(color: Colors.red)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  void _showCreateAccountModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Form(
          key: _registerFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Criar Conta', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pink)),
              const SizedBox(height: 16),
              _buildTextField(controller: usernameController, label: 'Nome', icon: Icons.person),
              const SizedBox(height: 16),
            _buildTextField(controller: regPhoneController, label: 'Telefone', icon: Icons.phone, formatter: [_phoneMaskFormatter]),
              const SizedBox(height: 16),
              _buildTextField(controller: regPasswordController, label: 'Senha', icon: Icons.lock, obscure: true),
              const SizedBox(height: 24),
              _buildGradientButton('Criar Conta', _handleCreateAccount),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    List<TextInputFormatter>? formatter,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      inputFormatters: formatter,
      obscureText: obscure,
      validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.pink),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildGradientButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: _isLoading ? null : const LinearGradient(colors: [Colors.pink, Colors.pinkAccent]),
          color: _isLoading ? Colors.grey[300] : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: 200,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              : Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    regPhoneController.dispose();
    regPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  width: screenWidth > 400 ? 400 : screenWidth * 0.9,
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Bem-vindo à Oficina do Bolo!', style: TextStyle(color: Colors.pink, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        _buildTextField(controller: phoneController, label: 'Telefone', icon: Icons.phone, formatter: [_phoneMaskFormatter]),
                        const SizedBox(height: 16),
                        _buildTextField(controller: passwordController, label: 'Senha', icon: Icons.lock, obscure: true),
                        Row(
                          children: [
                            Checkbox(value: _rememberMe, onChanged: _toggleRememberMe, activeColor: Colors.pink),
                            const Text('Lembrar-me'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildGradientButton('Entrar', _handleLogin),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _isLoading ? null : _showCreateAccountModal,
                          child: const Text('Criar Conta', style: TextStyle(color: Colors.pink, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
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
