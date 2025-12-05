import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project1/models/job_model.dart';
import 'dart:io';

class JobService {
  final String baseUrl = "http://10.0.2.2:4000/api/jobs";

  // Get all jobs
  Future<List<JobCategory>> getJobs() async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => JobCategory.fromJson(json)).toList();
    } else {
      throw Exception("Gagal mengambil data job");
    }
  }

  // Create job with image
  Future<JobCategory> createJob(JobCategory job, List<File> imageFiles) async {
    final url = Uri.parse(baseUrl);
    var request = http.MultipartRequest('POST', url);

    request.fields['job_name'] = job.jobName;
    request.fields['description'] = job.description;
    request.fields['category'] = job.category;
    request.fields['applicant'] = job.applicant.toString();

    if (imageFiles.isNotEmpty) {
      var file = await http.MultipartFile.fromPath('image', imageFiles.first.path);
      request.files.add(file);
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return JobCategory.fromJson(data["jobCategory"]);
    } else {
      throw Exception("Gagal membuat job: ${response.body}");
    }
  }

  // Update job with optional image
  Future<JobCategory> updateJob(String id, JobCategory job, {List<File>? imageFiles}) async {
    final url = Uri.parse("$baseUrl/$id");

    if (imageFiles != null && imageFiles.isNotEmpty) {
      var request = http.MultipartRequest('PUT', url);
      
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
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(job.toJson()),
      );

      if (response.statusCode == 200) {
        return JobCategory.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Gagal memperbarui job");
      }
    }
  }

  // Delete job
  Future<bool> deleteJob(String id) async {
    final url = Uri.parse("$baseUrl/$id");
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception("Gagal menghapus job");
    }
  }
}