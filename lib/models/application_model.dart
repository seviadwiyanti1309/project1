class ApplicationModel {
  final String id;
  final String? jobName;
  final String? category;
  final String cv;
  final String status;
  final DateTime createdAt;

  ApplicationModel({
    required this.id,
    this.jobName,
    this.category,
    required this.cv,
    required this.status,
    required this.createdAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['_id'] ?? '',
      jobName: json['jobCategoryId'] != null
          ? json['jobCategoryId']['job_name']
          : null,
      category: json['jobCategoryId'] != null
          ? json['jobCategoryId']['category']
          : null,
      cv: json['cv'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
