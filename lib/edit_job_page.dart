import 'package:flutter/material.dart';
import 'package:project1/models/job_model.dart';
import 'package:project1/services/job_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditJobPage extends StatefulWidget {
  final JobCategory job;

  const EditJobPage({super.key, required this.job});

  @override
  State<EditJobPage> createState() => _EditJobPageState();
}

class _EditJobPageState extends State<EditJobPage> {
  final _formKey = GlobalKey<FormState>();
  final JobService _jobService = JobService();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _jobNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _applicantController;
  late String _selectedCategory;
  
  List<File> _selectedImages = [];
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    _jobNameController = TextEditingController(text: widget.job.jobName);
    _descriptionController = TextEditingController(text: widget.job.description);
    _applicantController = TextEditingController(text: widget.job.applicant.toString());
    _selectedCategory = widget.job.category;
    _existingImageUrl = widget.job.image?.toString();
  }

  @override
  void dispose() {
    _jobNameController.dispose();
    _descriptionController.dispose();
    _applicantController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImages = [File(pickedFile.path)];
      });
    }
  }

  String? _getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return null;
    
    String cleanPath = imagePath
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll(' ', '')
        .trim();

    if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
      return cleanPath;
    }

    if (!cleanPath.startsWith('/')) {
      cleanPath = '/$cleanPath';
    }
    
    return 'http://10.0.2.2:4000$cleanPath';
  }

  Future<void> _updateJob() async {
    if (_formKey.currentState!.validate()) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

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

        await _jobService.updateJob(
          widget.job.id, 
          updatedJob,
          imageFiles: _selectedImages.isNotEmpty ? _selectedImages : null,
        );

        if (!mounted) return;
        Navigator.pop(context);
        Navigator.pop(context, true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job berhasil diupdate!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal update job: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildImagePreview() {
    if (_selectedImages.isNotEmpty) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              _selectedImages.first,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Foto Baru',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }
    
    final imageUrl = _getFullImageUrl(_existingImageUrl);
    
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.broken_image, size: 50, color: Colors.red),
                  const SizedBox(height: 8),
                  const Text('Gagal memuat foto'),
                ],
              ),
            );
          },
        ),
      );
    }
    
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
          SizedBox(height: 8),
          Text('Tidak ada foto', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Job"),
        backgroundColor: const Color(0xFF7D4CC2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Foto Job",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: _buildImagePreview(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: Text(
                        _selectedImages.isEmpty ? "Pilih Foto Baru" : "Ganti Foto",
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  if (_selectedImages.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedImages.clear();
                        });
                      },
                      icon: const Icon(Icons.cancel),
                      label: const Text("Batal"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _jobNameController,
                decoration: const InputDecoration(
                  labelText: "Nama Job",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Tidak boleh kosong" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: "Deskripsi",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? "Tidak boleh kosong" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _applicantController,
                decoration: const InputDecoration(
                  labelText: "Jumlah Pelamar",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Tidak boleh kosong" : null,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Kategori",
                  border: OutlineInputBorder(),
                ),
                items: ["IT", "Restaurant", "Hukum", "Marketing", "Finance"]
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _updateJob,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Update Job",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}