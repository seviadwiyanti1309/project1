import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:project1/services/apply_services.dart';
import '../services/job_service.dart';
import '../models/job_model.dart';


class ApplyJobPage extends StatefulWidget {
  final JobCategory job;
  const ApplyJobPage({super.key, required this.job});

  @override
  State<ApplyJobPage> createState() => _ApplyJobPageState();
}

class _ApplyJobPageState extends State<ApplyJobPage> {
  File? selectedFile;
  bool isSubmitting = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submitCV() async {
    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan pilih file CV terlebih dahulu")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final response = await ApplyServices().applyJob(
        jobId: widget.job.id,
        cvFile: selectedFile!,
      );

      if (response["success"]) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("CV berhasil dikirim!")),
        );
        Navigator.pop(context); // kembali ke halaman JobCategory
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: ${response['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Apply: ${widget.job.jobName}"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Upload CV (PDF) untuk melamar job ini",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.upload_file,color: Colors.white),
              label: Text(
                selectedFile == null
                    ? "Pilih File CV"
                    : "File Dipilih: ${selectedFile!.path.split('/').last}",
                    style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSubmitting ? null : _submitCV,
              child: isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Submit CV", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
