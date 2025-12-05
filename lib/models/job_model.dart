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
          : (json['images'] != null
              ? List<String>.from(json['images'])
              : []),

      createdAt: json['createdAt'] != null && json['createdAt'] != ""
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),

      updatedAt: json['updatedAt'] != null && json['updatedAt'] != ""
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
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

  String get firstImage => image.isNotEmpty ? image.first : '';
}
