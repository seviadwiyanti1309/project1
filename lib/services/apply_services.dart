import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'auth_services.dart';

class ApplyServices {
  final String baseUrl = "http://10.0.2.2:4000/api/applications"; 

  Future<Map<String, dynamic>> applyJob({
    required String jobId,
    required File cvFile,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/apply');

      final token = await AuthServices().getToken();
      if (token == null) {
        return {"success": false, "message": "Token tidak ditemukan"};
      }

      final request = http.MultipartRequest('POST', uri);

      // Field jobCategoryId
      request.fields['jobCategoryId'] = jobId;

      // Tambahkan file CV
      request.files.add(
        http.MultipartFile(
          'cv',
          cvFile.readAsBytes().asStream(),
          cvFile.lengthSync(),
          filename: path.basename(cvFile.path),
          contentType: MediaType('application', 'pdf'),
        ),
      );

      // Authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Kirim request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return {"success": true, "message": "CV berhasil dikirim"};
      } else {
        return {"success": false, "message": response.body};
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
}
