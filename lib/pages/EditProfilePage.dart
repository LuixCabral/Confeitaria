import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:app_confeitaria/localdata/DatabaseHelper.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) # ####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final db = DatabaseHelper.instance;
    final userData = await db.getUser();
    if (userData.isNotEmpty) {
      setState(() {
        _nameController.text = userData[0]['name'];
        _phoneController.text = userData[0]['phone'];
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveUserData() async {
    final db = DatabaseHelper.instance;
    await db.insertUser(_nameController.text, _phoneController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Dados salvos com sucesso!")),
    );
    Navigator.pop(context); // Volta para a página de perfil
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Perfil"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nome",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Telefone",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [_phoneMaskFormatter],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Salvar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}