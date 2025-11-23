import 'package:flutter/material.dart';

class JobPage extends StatefulWidget {
  const JobPage({super.key});

  @override
  State<JobPage> createState() => _JobPageState();
}

class _JobPageState extends State<JobPage> {
  // State untuk search query
  String searchQuery = '';
  
  // State untuk filter kategori
  String selectedCategory = 'All';
  
  // Daftar job categories
  final List<Map<String, String>> jobCategories = [
    {
      'title': 'Jaksa',
      'description': 'pegawai pemerintah dalam bidang hukum yang bertugas menyampaikan dakwaan',
      'imagePath': 'assets/jaksa.png',
      'category': 'Hukum',
    },
    {
      'title': 'Guru',
      'description': 'pegawai Negeri sipil yang tugas utamanya mendidik, mengarahkan, dan mengevaluasi peserta didik.',
      'imagePath': 'assets/guru.png',
      'category': 'Pendidikan',
    },
    {
      'title': 'Hakim',
      'description': 'yang melakukan tugas kekuasaan kehakiman dan menyelesaikan perkara pidana dan perdata.',
      'imagePath': 'assets/hakim.png',
      'category': 'Hukum',
    },
  ];

  // Filter jobs berdasarkan search dan category
  List<Map<String, String>> get filteredJobs {
    return jobCategories.where((job) {
      final matchesSearch = job['title']!.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = selectedCategory == 'All' || job['category'] == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // Title
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          "Job Categories",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Find your job here",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Search bar (now functional!)
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: "Search job",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.tune, color: Colors.grey),
                          onPressed: () {
                            _showFilterDialog();
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Category filter chips
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildCategoryChip('All'),
                        const SizedBox(width: 10),
                        _buildCategoryChip('Hukum'),
                        const SizedBox(width: 10),
                        _buildCategoryChip('Pendidikan'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Job Cards List
            Expanded(
              child: filteredJobs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No jobs found",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: filteredJobs.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 15),
                      itemBuilder: (context, index) {
                        final job = filteredJobs[index];
                        return JobCard(
                          title: job['title']!,
                          description: job['description']!,
                          imagePath: job['imagePath']!,
                          category: job['category']!,
                          onTap: () {
                            _showJobDetails(job);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Category Chip Widget
  Widget _buildCategoryChip(String category) {
    final isSelected = selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7D4CC2) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Show Filter Dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Jobs'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Categories'),
              leading: Radio<String>(
                value: 'All',
                groupValue: selectedCategory,
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Hukum'),
              leading: Radio<String>(
                value: 'Hukum',
                groupValue: selectedCategory,
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Pendidikan'),
              leading: Radio<String>(
                value: 'Pendidikan',
                groupValue: selectedCategory,
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show Job Details
  void _showJobDetails(Map<String, String> job) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7D4CC2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.work_outline,
                    size: 32,
                    color: Color(0xFF7D4CC2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['title']!,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        job['category']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              job['description']!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Applied for ${job['title']}!'),
                      backgroundColor: const Color(0xFF7D4CC2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7D4CC2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
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
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon/Image Container
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.work_outline,
                    size: 40,
                    color: Color(0xFF7D4CC2),
                  );
                },
              ),
            ),

            const SizedBox(width: 15),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Details",
                      style: TextStyle(
                        color: Color(0xFF7D4CC2),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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