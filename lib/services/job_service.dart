import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project1/models/job_model.dart';

class JobService {
  final String baseUrl = "http://10.0.2.2:4000/api/jobs";
  
  //get
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
  
  //post 
  Future<JobCategory> createJob(JobCategory job) async {
    final url = Uri.parse(baseUrl);
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(job.toJson()),
    );
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      return JobCategory.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Gagal membuat job");
    }
  }
  
  //PUT
  Future<JobCategory> updateJob(String id, JobCategory job) async {
    final url = Uri.parse("$baseUrl/$id");
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
  
  //Delete
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