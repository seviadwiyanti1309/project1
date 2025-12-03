import 'package:flutter/material.dart';
import 'package:project1/models/job_model.dart';
import 'package:project1/services/job_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateJobPage extends StatefulWidget {
  const CreateJobPage({Key? key}) : super(key: key);

  @override
  State<CreateJobPage> createState() => _CreateJobPageState();
}

class _CreateJobPageState extends State<CreateJobPage> {
  final _formKey = GlobalKey<FormState>();
  final JobService _jobService = JobService();
  final ImagePicker _picker = ImagePicker();

  // Controllers
  final TextEditingController _jobNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _applicantController = TextEditingController();

  String _selectedCategory = 'IT';
  final List<String> _categories = ['IT', 'Restaurant', 'Hukum', 'Marketing', 'Finance'];

  List<File> _imageFiles = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _jobNameController.dispose();
    _descriptionController.dispose();
    _applicantController.dispose();
    super.dispose();
  }

  // Pick gambar dari galeri
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _imageFiles.add(File(image.path));
        });
      }
    } catch (e) {
      _showSnackBar('Gagal memilih gambar: $e', Colors.red);
    }
  }

  // Pick gambar dari kamera
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image =
          await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);

      if (image != null) {
        setState(() {
          _imageFiles.add(File(image.path));
        });
      }
    } catch (e) {
      _showSnackBar('Gagal mengambil foto: $e', Colors.red);
    }
  }

  // Show pilihan galeri / kamera
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pilih Sumber Gambar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF7D4CC2)),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF7D4CC2)),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_imageFiles.isEmpty) {
        _showSnackBar('Tambahkan minimal satu gambar', Colors.orange);
        return;
      }

      setState(() => _isLoading = true);

      try {
        // Pakai nama file sebagai dummy storage image URL
        final imageNames =
            _imageFiles.map((file) => file.path.split('/').last).toList();

        final job = JobCategory(
          id: '',
          jobName: _jobNameController.text,
          description: _descriptionController.text,
          category: _selectedCategory,
          applicant: int.parse(_applicantController.text),
          image: imageNames,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _jobService.createJob(job);

        if (mounted) {
          _showSnackBar('Job berhasil dibuat! 🎉', Colors.green);
          Navigator.pop(context, true);
        }
      } catch (e) {
        _showSnackBar('Gagal membuat job: $e', Colors.red);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF7D4CC2),
        title: const Text('Buat Job Baru', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TITLE CARD
              _buildHeaderCard(),
              const SizedBox(height: 20),

              // Input Fields
              _buildLabel('Nama Job'),
              _buildTextField(_jobNameController, 'Contoh: Frontend Developer', Icons.work),
              const SizedBox(height: 20),

              _buildLabel('Kategori'),
              _buildDropdown(),
              const SizedBox(height: 20),

              _buildLabel('Deskripsi'),
              _buildTextField(_descriptionController, 'Isi deskripsi pekerjaan...', Icons.description,
                  maxLines: 4),
              const SizedBox(height: 20),

              _buildLabel('Jumlah Pelamar'),
              _buildTextField(_applicantController, 'Contoh: 10', Icons.people,
                  keyboard: TextInputType.number),
              const SizedBox(height: 25),

              _buildLabel('Gambar Job'),
              const SizedBox(height: 10),
              _buildImageButtons(),
              const SizedBox(height: 15),

              if (_imageFiles.isNotEmpty) _buildImageGrid(),

              const SizedBox(height: 30),

              // Submit Button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- UI Components ---------------- //

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: const [
          Icon(Icons.work_outline, size: 35, color: Color(0xFF7D4CC2)),
          SizedBox(width: 15),
          Text(
            'Informasi Job',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF7D4CC2)),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
      validator: (value) => value!.isEmpty ? 'Tidak boleh kosong' : null,
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: (v) => setState(() => _selectedCategory = v!),
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }

  Widget _buildImageButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _pickImageFromGallery,
            icon: const Icon(Icons.photo_library, color: Colors.white),
            label: const Text('Galeri', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7D4CC2)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _pickImageFromCamera,
            icon: const Icon(Icons.camera_alt,color: Colors.white),
            label: const Text('Kamera', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7D4CC2)),
          ),
        ),
      ],
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _imageFiles.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemBuilder: (context, index) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(_imageFiles[index], fit: BoxFit.cover, width: double.infinity),
            ),
            Positioned(
              right: 5,
              top: 5,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: const CircleAvatar(radius: 12, backgroundColor: Colors.red, child: Icon(Icons.close, size: 14)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7D4CC2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Buat Job', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
