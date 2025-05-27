import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_confeitaria/pages/order_history_page.dart';
import 'package:app_confeitaria/service/auth_service.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = "Carregando...";
  String _phone = "Carregando...";
  bool _isLoading = true;
  String? _profileImagePath; // Armazena o caminho da imagem

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final authService = AuthService();
      final name = await authService.getUserName();
      final phone = await authService.getUserPhone();
      final imagePath = await authService.getProfileImagePath(); // Carrega o caminho da imagem
      setState(() {
        _name = name ?? "Não informado";
        _phone = phone ?? "Não informado";
        _profileImagePath = imagePath; // Atualiza o caminho da imagem
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
      setState(() {
        _name = "Erro ao carregar";
        _phone = "Erro ao carregar";
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Selecionar Imagem"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text("Galeria"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text("Câmera"),
          ),
        ],
      ),
    );
    if (source != null) {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null && mounted) {
        final authService = AuthService();
        await authService.saveProfileImagePath(pickedFile.path);
        setState(() {
          _profileImagePath = pickedFile.path;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    final authService = AuthService();
    await authService.logout(); // Remove os dados do shared_preferences
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login'); // Redireciona para a tela de login
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Perfil",
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            ProfilePic(
              imagePath: _profileImagePath, // Passa o caminho da imagem para o ProfilePic
              onCameraPressed: _pickImage, // Passa a função para selecionar a imagem
            ),
            const SizedBox(height: 20),
            ProfileMenu(
              text: "Minha Conta",
              subtitle: "Nome: $_name\nTelefone: $_phone",
              icon: "assets/icons/User Icon.svg",
              press: () {},
            ),
            ProfileMenu(
              text: "Ver Histórico",
              icon: "assets/icons/History.svg",
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrderHistoryPage()),
                );
              },
            ),
            ProfileMenu(
              text: "Sair",
              icon: "assets/icons/Log out.svg",
              press: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Sair'),
                    content: const Text('Deseja realmente sair da conta?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Não'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Sim'),
                      ),
                    ],
                  ),
                );
                if (shouldLogout == true) {
                  await _handleLogout();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePic extends StatelessWidget {
  const ProfilePic({
    super.key,
    this.imagePath, // Caminho da imagem salva
    required this.onCameraPressed, // Função para selecionar a imagem
  });

  final String? imagePath;
  final VoidCallback onCameraPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 115,
      width: 115,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            backgroundImage: imagePath != null && File(imagePath!).existsSync()
                ? FileImage(File(imagePath!)) // Usa a imagem salva se existir
                : const NetworkImage("https://i.postimg.cc/0jqKB6mS/Profile-Image.png") as ImageProvider, // Imagem padrão
          ),
          Positioned(
            right: -16,
            bottom: 0,
            child: SizedBox(
              height: 46,
              width: 46,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: const BorderSide(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFFF5F6F9),
                ),
                onPressed: onCameraPressed, // Chama a função para selecionar a imagem
                child: SvgPicture.string(cameraIcon),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    super.key,
    required this.text,
    this.subtitle,
    required this.icon,
    this.press,
  });

  final String text, icon;
  final String? subtitle;
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFFF7643),
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: const Color(0xFFF5F6F9),
        ),
        onPressed: press,
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              colorFilter:
              const ColorFilter.mode(Color(0xFFFF7643), BlendMode.srcIn),
              width: 22,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      color: Color(0xFF757575),
                      fontSize: 16,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: Color(0xFF757575),
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF757575),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

const cameraIcon =
'''<svg width="20" height="16" viewBox="0 0 20 16" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M10 12.0152C8.49151 12.0152 7.26415 10.8137 7.26415 9.33902C7.26415 7.86342 8.49151 6.6619 10 6.6619C11.5085 6.6619 12.7358 7.86342 12.7358 9.33902C12.7358 10.8137 11.5085 12.0152 10 12.0152ZM10 5.55543C7.86698 5.55543 6.13208 7.25251 6.13208 9.33902C6.13208 11.4246 7.86698 13.1217 10 13.1217C12.133 13.1217 13.8679 11.4246 13.8679 9.33902C13.8679 7.25251 12.133 5.55543 10 5.55543ZM18.8679 13.3967C18.8679 14.2226 18.1811 14.8935 17.3368 14.8935H2.66321C1.81887 14.8935 1.13208 14.2226 1.13208 13.3967V5.42346C1.13208 4.59845 1.81887 3.92664 2.66321 3.92664H4.75C5.42453 3.92664 6.03396 3.50952 6.26604 2.88753L6.81321 1.41746C6.88113 1.23198 7.06415 1.10739 7.26604 1.10739H12.734C12.9358 1.10739 13.1189 1.23198 13.1877 1.41839L13.734 2.88845C13.966 3.50952 14.5755 3.92664 15.25 3.92664H17.3368C18.1811 3.92664 18.8679 4.59845 18.8679 5.42346V13.3967ZM17.3368 2.82016H15.25C15.0491 2.82016 14.867 2.69466 14.7972 2.50917L14.2519 1.04003C14.0217 0.418041 13.4113 0 12.734 0H7.26604C6.58868 0 5.9783 0.418041 5.74906 1.0391L5.20283 2.50825C5.13302 2.69466 4.95094 2.82016 4.75 2.82016H2.66321C1.19434 2.82016 0 3.98846 0 5.42346V13.3967C0 14.8326 1.19434 16 2.66321 16H17.3368C18.8057 16 20 14.8326 20 13.3967V5.42346C20 3.98846 18.8057 2.82016 17.3368 2.82016Z" fill="#757575"/>
</svg>
''';