import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_services.dart';
import '../models/application_model.dart';

class ApplicationServices {
  final String baseUrl = "http://10.0.2.2:4000/api/applications";

  Future<List<ApplicationModel>> getMyApplications() async {
    try {
      final uri = Uri.parse('$baseUrl/my-applications');

      final token = await AuthServices().getToken();
      if (token == null) {
        throw Exception("Token tidak ditemukan");
      }

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // backend kamu return array, jadi langsung map ke list
        final List<ApplicationModel> apps = (data as List)
            .map((item) => ApplicationModel.fromJson(item))
            .toList();

        return apps;
      } else {
        throw Exception("Gagal mengambil data: ${response.body}");
      }
    } catch (e) {
      rethrow;
    }
  }
}
