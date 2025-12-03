import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthServices {
  final String baseUrl = "http://10.0.2.2:4000/api/auth";
  final storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await storage.write(key: "token", value: data["token"]);
      return {"success": true, "user": data["user"]};
    }
    return {"success": false, "message": data["message"]};
  }

  // FUNGSI LOGOUT BARU
  Future<Map<String, dynamic>> logout() async {
    try {
      // Ambil token dari storage
      final token = await storage.read(key: "token");
      
      if (token == null) {
        return {"success": false, "message": "Token tidak ditemukan"};
      }

      final url = Uri.parse("$baseUrl/logout");
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      // Hapus token dari storage (wajib dilakukan)
      await storage.delete(key: "token");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"success": true, "message": data["message"]};
      }

      // Tetap return success karena token sudah dihapus dari local
      return {"success": true, "message": "Logout berhasil"};
    } catch (e) {
      // Tetap hapus token meski ada error
      await storage.delete(key: "token");
      return {"success": true, "message": "Logout berhasil"};
    }
  }

  // Fungsi tambahan untuk cek apakah user sudah login
  Future<bool> isLoggedIn() async {
    final token = await storage.read(key: "token");
    return token != null;
  }

  // Fungsi untuk mendapatkan token
  Future<String?> getToken() async {
    return await storage.read(key: "token");
  }
}