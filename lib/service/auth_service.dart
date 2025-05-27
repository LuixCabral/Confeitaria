import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  Future<bool> login(String phone, String password) async {
    try {
      final data = await ApiService.login(phone, password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_authenticated', true);
      await prefs.setString('user_phone', data['user']['phone']);
      await prefs.setString('user_name', data['user']['name']);
      return true;
    } catch (e) {
      throw Exception('Erro ao conectar à API: $e');
    }
  }

  Future<bool> createAccount(String username, String phone, String password) async {
    try {
      await ApiService.createAccount(username, phone, password);
      // Auto-login after account creation
      return await login(phone, password);
    } catch (e) {
      throw Exception('Erro ao criar conta: $e');
    }
  }

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_authenticated') ?? false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_authenticated');
    await prefs.remove('user_phone');
    await prefs.remove('user_name');
    await prefs.remove('profile_image_path');
  }

  Future<String?> getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_phone');
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }

  Future<void> saveProfileImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', path);
  }

  Future<String?> getProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_image_path');
  }
}