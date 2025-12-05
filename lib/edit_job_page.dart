import 'package:flutter/material.dart';
import 'package:project1/models/job_model.dart';
import 'package:project1/services/job_service.dart';

class EditJobPage extends StatefulWidget {
  final JobCategory job;

  const EditJobPage({super.key, required this.job});

  @override
  State<EditJobPage> createState() => _EditJobPageState();
}

class _EditJobPageState extends State<EditJobPage> {
  final _formKey = GlobalKey<FormState>();
  final JobService _jobService = JobService();

  late TextEditingController _jobNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _applicantController;

  String _selectedCategory = "IT";

  @override
  void initState() {
    super.initState();

    _jobNameController = TextEditingController(text: widget.job.jobName);
    _descriptionController = TextEditingController(text: widget.job.description);
    _applicantController = TextEditingController(text: widget.job.applicant.toString());
    _selectedCategory = widget.job.category;
  }

  @override
  void dispose() {
    _jobNameController.dispose();
    _descriptionController.dispose();
    _applicantController.dispose();
    super.dispose();
  }

  Future<void> _updateJob() async {
    if (_formKey.currentState!.validate()) {
      final updatedJob = JobCategory(
        id: widget.job.id,
        jobName: _jobNameController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        applicant: int.parse(_applicantController.text),
        image: widget.job.image,
        createdAt: widget.job.createdAt,
        updatedAt: DateTime.now(),
      );

      await _jobService.updateJob(widget.job.id, updatedJob);

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Job"),
        backgroundColor: const Color(0xFF7D4CC2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _jobNameController,
                decoration: const InputDecoration(labelText: "Nama Job"),
                validator: (v) => v!.isEmpty ? "Tidak boleh kosong" : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Deskripsi"),
                validator: (v) => v!.isEmpty ? "Tidak boleh kosong" : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _applicantController,
                decoration: const InputDecoration(labelText: "Jumlah Pelamar"),
                validator: (v) => v!.isEmpty ? "Tidak boleh kosong" : null,
              ),
              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: ["IT", "Restaurant", "Hukum", "Marketing", "Finance"]
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _updateJob,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text("Update Job", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
