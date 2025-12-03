class JobCategory {
  final String id;
  final String jobName;
  final String description;
  final String category;
  final int applicant;
  final List<String> image;
  final DateTime createdAt;
  final DateTime updatedAt;

  JobCategory({
    required this.id,
    required this.jobName,
    required this.description,
    required this.category,
    required this.applicant,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JobCategory.fromJson(Map<String, dynamic> json) {
    return JobCategory(
      id: json['_id'] ?? '',
      jobName: json['job_name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      applicant: json['applicant'] ?? 0,
      image: json['image'] != null
          ? List<String>.from(json['image'])
          : <String>[],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "job_name": jobName,
      "description": description,
      "category": category,
      "applicant": applicant,
      "image": image,
    };
  }
}
