// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class AuthServices {
//   final String baseUrl = "http://10.0.2.2:4000/api/auth";
//   final storage = const FlutterSecureStorage();

//   Future<Map<String, dynamic>> login(String email, String password) async {
//     final url = Uri.parse("$baseUrl/login");
//     final response = await http.post(
//       url,
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "email": email,
//         "password": password,
//       }),
//     );

//     final data = jsonDecode(response.body);
//     if (response.statusCode == 200) {
//       await storage.write(key: "token", value: data["token"]);
//       return {"success": true, "user": data["user"]};
//     }
//     return {"success": false, "message": data["message"]};
//   }


//   Future<Map<String, dynamic>> logout() async {
//     try {
     
//       final token = await storage.read(key: "token");
      
//       if (token == null) {
//         return {"success": false, "message": "Token tidak ditemukan"};
//       }

//       final url = Uri.parse("$baseUrl/logout");
//       final response = await http.post(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//         },
//       );

      
//       await storage.delete(key: "token");

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return {"success": true, "message": data["message"]};
//       }

    
//       return {"success": true, "message": "Logout berhasil"};
//     } catch (e) {
      
//       await storage.delete(key: "token");
//       return {"success": true, "message": "Logout berhasil"};
//     }
//   }

  
//   Future<bool> isLoggedIn() async {
//     final token = await storage.read(key: "token");
//     return token != null;
//   }

 
//   Future<String?> getToken() async {
//     return await storage.read(key: "token");
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class AuthServices {
  final String baseUrl = "http://10.0.2.2:4000/api/auth";
  final storage = const FlutterSecureStorage();

  // Login dengan return UserModel
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
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
        // Simpan token
        await storage.write(key: "token", value: data["token"]);
        
        final user = UserModel.fromJson(data["user"]);
        await storage.write(key: "user_data", value: jsonEncode(user.toJson()));
        
        return {
          "success": true, 
          "user": user,
          "message": "Login berhasil"
        };
      }

      return {
        "success": false, 
        "message": data["message"] ?? "Login gagal"
      };
    } catch (e) {
      return {
        "success": false, 
        "message": "Koneksi error: ${e.toString()}"
      };
    }
  }

  // Logout
  Future<Map<String, dynamic>> logout() async {
    try {
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

      // Hapus token dan data user
      await storage.delete(key: "token");
      await storage.delete(key: "user_data");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"success": true, "message": data["message"]};
      }

      return {"success": true, "message": "Logout berhasil"};
    } catch (e) {
      // Tetap hapus local storage meskipun request gagal
      await storage.delete(key: "token");
      await storage.delete(key: "user_data");
      return {"success": true, "message": "Logout berhasil"};
    }
  }

  // Cek apakah sudah login
  Future<bool> isLoggedIn() async {
    final token = await storage.read(key: "token");
    return token != null;
  }

  // Get Token
  Future<String?> getToken() async {
    return await storage.read(key: "token");
  }

  // Get User Data
  Future<UserModel?> getCurrentUser() async {
    try {
      final userData = await storage.read(key: "user_data");
      if (userData != null) {
        return UserModel.fromJson(jsonDecode(userData));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Cek Role User
  Future<String?> getUserRole() async {
    final user = await getCurrentUser();
    return user?.role;
  }

  // Helper: Cek apakah HR
  Future<bool> isHR() async {
    final role = await getUserRole();
    return role == "hr";
  }

  // Helper: Cek apakah User biasa
  Future<bool> isRegularUser() async {
    final role = await getUserRole();
    return role == "user";
  }
}