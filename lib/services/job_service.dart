import 'dart:convert';
import 'package:http/http.dart' as http;


class JobService {
  final String baseUrl = "http://localhost:4000/api/jobs";

  Future<List<dynamic>> getJobs() async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal mengambil data job");
    }
  }
}