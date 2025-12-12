import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:project1/models/job_model.dart';
import 'auth_services.dart';

class JobService {
  final String baseUrl = "http://10.0.2.2:4000/api/jobs";
  final AuthServices _authService = AuthServices();

  //GET ALL JOBS (USER & HR)
  Future<List<JobCategory>> getJobs() async {
    final url = Uri.parse(baseUrl);
    final token = await _authService.getToken();
    if (token == null) throw Exception("Token tidak ditemukan. Silakan login ulang.");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    // print('Status code: ${response.statusCode}');
    // print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => JobCategory.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized: Token tidak valid atau expired");
    } else {
      throw Exception("Gagal mengambil data job: ${response.statusCode}");
    }
  }

  // CREATE JOB (HR ONLY)
  Future<JobCategory> createJob(JobCategory job, {List<File>? imageFiles}) async {
    final url = Uri.parse(baseUrl);
    final token = await _authService.getToken();
    if (token == null) throw Exception("Token tidak ditemukan");

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['job_name'] = job.jobName;
    request.fields['description'] = job.description;
    request.fields['category'] = job.category;
    request.fields['applicant'] = job.applicant.toString();

    if (imageFiles != null && imageFiles.isNotEmpty) {
  var file = await http.MultipartFile.fromPath('image', imageFiles.first.path);
  request.files.add(file);
}


    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return JobCategory.fromJson(data["jobCategory"]);
    } else {
      throw Exception("Gagal membuat job: ${response.body}");
    }
  }

  // UPDATE JOB (HR ONLY)
  Future<JobCategory> updateJob(String id, JobCategory job, {List<File>? imageFiles}) async {
    final url = Uri.parse("$baseUrl/$id");
    final token = await _authService.getToken();
    if (token == null) throw Exception("Token tidak ditemukan");

    if (imageFiles != null && imageFiles.isNotEmpty) {
      var request = http.MultipartRequest('PUT', url);
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['job_name'] = job.jobName;
      request.fields['description'] = job.description;
      request.fields['category'] = job.category;
      request.fields['applicant'] = job.applicant.toString();

      var file = await http.MultipartFile.fromPath('image', imageFiles.first.path);
      request.files.add(file);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return JobCategory.fromJson(data);
      } else {
        throw Exception("Gagal memperbarui job: ${response.body}");
      }
    } else {
      // Update tanpa image
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(job.toJson()),
      );

      if (response.statusCode == 200) {
        return JobCategory.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Gagal memperbarui job: ${response.body}");
      }
    }
  }

  // DELETE JOB (HR ONLY)
  Future<bool> deleteJob(String id) async {
    final url = Uri.parse("$baseUrl/$id");
    final token = await _authService.getToken();
    if (token == null) throw Exception("Token tidak ditemukan");

    final response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized: Token tidak valid atau expired");
    } else {
      throw Exception("Gagal menghapus job: ${response.body}");
    }
  }
}
