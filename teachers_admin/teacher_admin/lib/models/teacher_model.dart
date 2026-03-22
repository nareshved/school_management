class TeacherModel {
  final String? id;
  final String? userId;
  final String fullName;
  final String? subjectId;
  final String? subjectName;
  final String? phone;
  final String? email;
  final String? avatarUrl;
  final double rating;
  final bool isActive;
  final int studentCount;
  final double attendancePercent;
  final List<String> assignedClasses;
  final DateTime? createdAt;

  TeacherModel({
    this.id,
    this.userId,
    required this.fullName,
    this.subjectId,
    this.subjectName,
    this.phone,
    this.email,
    this.avatarUrl,
    this.rating = 0,
    this.isActive = true,
    this.studentCount = 0,
    this.attendancePercent = 0,
    this.assignedClasses = const [],
    this.createdAt,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    final subjectData = json['subjects'];
    final classesData = json['teacher_classes'] as List?;
    return TeacherModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      fullName: json['full_name'] as String,
      subjectId: json['subject_id'] as String?,
      subjectName: subjectData is Map ? subjectData['name'] as String? : null,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      assignedClasses: classesData?.map((e) {
            final cls = e['classes'];
            if (cls is Map) {
              return '${cls['name']}-${cls['section']}';
            }
            return '';
          }).where((s) => s.isNotEmpty).toList().cast<String>() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'subject_id': subjectId,
      'phone': phone,
      'email': email,
      'avatar_url': avatarUrl,
      'rating': rating,
      'is_active': isActive,
    };
  }

  String get primaryClass =>
      assignedClasses.isNotEmpty ? assignedClasses.first : 'Unassigned';
}
