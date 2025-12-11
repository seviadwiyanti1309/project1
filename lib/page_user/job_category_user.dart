import 'package:flutter/material.dart';
import 'package:project1/page_user/apply_job_page.dart';
import '../models/job_model.dart';
import '../services/job_service.dart';
import '../services/auth_services.dart';

class JobCategoryPage extends StatefulWidget {
  const JobCategoryPage({super.key});

  @override
  State<JobCategoryPage> createState() => _JobCategoryPageState();
}

class _JobCategoryPageState extends State<JobCategoryPage> {
  late Future<List<JobCategory>> jobFuture;
  bool isHR = false;
  bool isLoadingRole = true;
  String userName = "";

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    await _checkUserRole();
    _refreshData();
  }

  Future<void> _checkUserRole() async {
    final authService = AuthServices();
    final hrStatus = await authService.isHR();
    final user = await authService.getCurrentUser();

    setState(() {
      isHR = hrStatus;
      userName = user?.name ?? "User";
      isLoadingRole = false;
    });
  }

  void _refreshData() {
    setState(() {
      jobFuture = JobService().getJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingRole) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Categories'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<JobCategory>>(
        future: jobFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada job tersedia"));
          }

          final jobs = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final job = jobs[index];
              return JobCard(
                title: job.jobName,
                description: job.description,
                imagePath: job.image.isNotEmpty ? job.image[0] : '',
                category: job.category,
                onTap: () {
                  // Bisa tampilkan dialog detail job
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ApplyJobPage(job: job),
                  ),
                );  
                },
              );
            },
          );
        },
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final String category;
  final VoidCallback? onTap;

  const JobCard({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imgUrl = imagePath.isEmpty ? "" : "http://10.0.2.2:4000/$imagePath";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF7D4CC2),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: imgUrl.isEmpty
                  ? const Icon(Icons.work_outline, size: 40, color: Color(0xFF7D4CC2))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        imgUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(description,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(category,
                        style: const TextStyle(
                            color: Color(0xFF7D4CC2),
                            fontWeight: FontWeight.bold,
                            fontSize: 10)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
