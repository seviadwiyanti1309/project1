import 'package:flutter/material.dart';
import 'package:project1/models/job_model.dart';
import 'package:project1/services/job_service.dart';
import 'package:project1/create_job_page.dart';

import 'edit_job_page.dart';

class JobPage extends StatefulWidget {
  const JobPage({super.key});

  @override
  State<JobPage> createState() => _JobPageState();
}

class _JobPageState extends State<JobPage> {
  String searchQuery = '';
  String selectedCategory = 'All';
  late Future<List<JobCategory>> jobFuture;

  @override
  void initState() {
    super.initState();
    jobFuture = JobService().getJobs();
  }

  void _refreshData() {
    setState(() {
      jobFuture = JobService().getJobs();
    });
  }

  List<JobCategory> filterJobs(List<JobCategory> jobs) {
    return jobs.where((job) {
      final title = job.jobName.toLowerCase();
      final category = job.category;
      
      final matchesSearch = title.contains(searchQuery.toLowerCase());
      final matchesCategory =
          selectedCategory == 'All' || category == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: FutureBuilder<List<JobCategory>>(
                future: jobFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF7D4CC2),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("No jobs available"),
                    );
                  }

                  final filtered = filterJobs(snapshot.data!);

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text("No jobs found"),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      final job = filtered[index];
                      return JobCard(
                        title: job.jobName,
                        description: job.description,
                        imagePath: job.image.isNotEmpty
                            ? job.image[0]
                            : '', // jika tidak ada gambar
                        category: job.category,
                        onTap: () => _showJobDetails(job),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateJobPage(),
            ),
          );
          if (result == true) {
            _refreshData();
          }
        },
        backgroundColor: const Color.fromARGB(255, 193, 149, 254),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Create Job',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            "Job Categories",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Find your job here",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // SEARCH BAR
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.search),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    onChanged: (value) => setState(() => searchQuery = value),
                    decoration: const InputDecoration(
                      hintText: "Search job",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // CATEGORY CHIPS
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryChip('All'),
                const SizedBox(width: 12),
                _buildCategoryChip('Restaurant'),
                _buildCategoryChip('Hukum'),
                _buildCategoryChip('IT'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7D4CC2) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showJobDetails(JobCategory job) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              job.jobName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 10),
            Text(job.description),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // EDIT BUTTON
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditJobPage(job: job),
                      ),
                    );

                    if (result == true) {
                      _refreshData();
                      _showSuccessAlert();
                    }
                  },
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text("Edit", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),

                // DELETE BUTTON
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);

                    final confirm = await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Hapus Job?"),
                        content: Text("Yakin ingin menghapus '${job.jobName}'?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Batal"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await JobService().deleteJob(job.id);
                      _refreshData();
                    }
                  },
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text("Delete", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ),
  );
}

  void _showSuccessAlert() {
    showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Berhasil"),
      content: const Text("Job berhasil diupdate!"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
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
    final String imgUrl = imagePath.isEmpty
        ? "" 
        : "http://10.0.2.2:4000/$imagePath"; 

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF7D4CC2),
          borderRadius: BorderRadius.circular(20),
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
                  ? const Icon(Icons.work_outline, size: 40)
                  : Image.network(
                      imgUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return const Icon(Icons.broken_image, size: 40);
                      },
                    ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    description,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: Color(0xFF7D4CC2),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}