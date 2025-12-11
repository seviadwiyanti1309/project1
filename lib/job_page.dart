import 'package:flutter/material.dart';
import 'package:project1/models/job_model.dart';
import 'package:project1/services/job_service.dart';
import 'package:project1/services/auth_services.dart';
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
  bool isHR = false;
  bool isLoadingRole = true;
  String userName = "";

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  // Initialize page data
  Future<void> _initPage() async {
    await _checkUserRole();
    _refreshData();
  }

  // Check if user is HR
  Future<void> _checkUserRole() async {
    try {
      final authService = AuthServices();
      final hrStatus = await authService.isHR();
      final user = await authService.getCurrentUser();
      
      print("👤 User role check:");
      print("   - Is HR: $hrStatus");
      print("   - User: ${user?.name}");
      print("   - Role: ${user?.role}");
      
      setState(() {
        isHR = hrStatus;
        userName = user?.name ?? "User";
        isLoadingRole = false;
      });
    } catch (e) {
      print("❌ Error checking role: $e");
      setState(() {
        isLoadingRole = false;
      });
    }
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
    if (isLoadingRole) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF7D4CC2),
          ),
        ),
      );
    }

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

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, 
                              size: 60, 
                              color: Colors.red
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Error",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${snapshot.error}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _refreshData,
                              icon: const Icon(Icons.refresh),
                              label: const Text("Coba Lagi"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7D4CC2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.work_off, 
                            size: 80, 
                            color: Colors.grey.shade400
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Belum ada job tersedia",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          if (isHR) ...[
                            const SizedBox(height: 8),
                            const Text(
                              "Buat job pertama Anda!",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  final filtered = filterJobs(snapshot.data!);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, 
                            size: 80, 
                            color: Colors.grey.shade400
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Tidak ada job yang sesuai",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      _refreshData();
                      await jobFuture;
                    },
                    color: const Color(0xFF7D4CC2),
                    child: ListView.separated(
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
                              : '',
                          category: job.category,
                          onTap: () => _showJobDetails(job),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Only show FAB if user is HR
      floatingActionButton: isHR 
        ? FloatingActionButton.extended(
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
          )
        : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Job Categories",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Hello, $userName",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              // Role badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isHR ? Colors.green : Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (isHR ? Colors.green : Colors.blue).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isHR ? Icons.admin_panel_settings : Icons.person,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isHR ? "HR" : "User",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                _buildCategoryChip('IT'),
                const SizedBox(width: 12),
                _buildCategoryChip('Restaurant'),
                const SizedBox(width: 12),
                _buildCategoryChip('Hukum'),
                const SizedBox(width: 12),
                _buildCategoryChip('Marketing'),
                const SizedBox(width: 12),
                _buildCategoryChip('Finance'),
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
    builder: (dialogContext) => Dialog(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Center(
              child: Text(
                job.jobName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            
            // Category badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF7D4CC2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  job.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              job.description,
              style: const TextStyle(fontSize: 14),
            ),
            
            const SizedBox(height: 12),
            
            // Applicants
            Row(
              children: [
                const Icon(Icons.people, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  "${job.applicant} Pelamar",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),

            // Only show Edit and Delete buttons if user is HR
            if (isHR)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(dialogContext);

                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditJobPage(job: job),
                          ),
                        );

                        if (result == true && mounted) {
                          _refreshData();
                          _showSuccessAlert("Job berhasil diupdate!");
                        }
                      },
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text("Edit", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final scaffoldContext = context;
                        Navigator.pop(dialogContext);
                        final confirm = await showDialog<bool>(
                          context: scaffoldContext,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Hapus Job?"),
                            content: Text("Yakin ingin menghapus '${job.jobName}'?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text("Batal"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text(
                                  "Hapus",
                                  style: TextStyle(color: Colors.red)
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          _deleteJobWithLoading(scaffoldContext, job);
                        }
                      },
                      icon: const Icon(Icons.delete, color: Colors.white),
                      label: const Text("Delete", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red
                      ),
                    ),
                  ),
                ],
              )
            else
              // For regular users, show "Close" button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7D4CC2),
                  ),
                  child: const Text(
                    "Close",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

void _deleteJobWithLoading(BuildContext ctx, JobCategory job) async {
  showDialog(
    context: ctx,
    barrierDismissible: false,
    builder: (loadingCtx) => WillPopScope(
      onWillPop: () async => false,
      child: const Dialog(
        backgroundColor: Colors.transparent,
        child: Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7D4CC2)),
                  ),
                  SizedBox(height: 16),
                  Text("Menghapus job..."),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  try {
    await JobService().deleteJob(job.id);
    
    if (mounted) {
      Navigator.of(ctx).pop();
    }
    if (mounted) {
      _refreshData();
      
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text("'${job.jobName}' berhasil dihapus"),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }

  } catch (e) {
    print("❌ ERROR: $e");

    if (mounted) {
      Navigator.of(ctx).pop();
    }

    if (mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text("Gagal menghapus: ${e.toString()}"),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

  void _showSuccessAlert(String message) {
    showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Berhasil"),
      content: Text(message),
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
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7D4CC2).withOpacity(0.3),
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
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF7D4CC2),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) {
                          return const Icon(
                            Icons.broken_image, 
                            size: 40,
                            color: Color(0xFF7D4CC2),
                          );
                        },
                      ),
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