class StudentModel {
  final String? id;
  final String? userId;
  final String fullName;
  final String? classId;
  final String? className;
  final String? section;
  final String? rollNumber;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? guardianName;
  final String? guardianRelationship;
  final String? guardianPhone;
  final String? guardianEmail;
  final String? addressStreet;
  final String? addressCity;
  final String? addressState;
  final String? addressZip;
  final String? avatarUrl;
  final bool isActive;
  final double? attendancePercent;
  final String? feeStatus;
  final DateTime? createdAt;

  StudentModel({
    this.id,
    this.userId,
    required this.fullName,
    this.classId,
    this.className,
    this.section,
    this.rollNumber,
    this.dateOfBirth,
    this.gender,
    this.guardianName,
    this.guardianRelationship,
    this.guardianPhone,
    this.guardianEmail,
    this.addressStreet,
    this.addressCity,
    this.addressState,
    this.addressZip,
    this.avatarUrl,
    this.isActive = true,
    this.attendancePercent,
    this.feeStatus,
    this.createdAt,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    final classData = json['classes'];
    return StudentModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      fullName: json['full_name'] as String,
      classId: json['class_id'] as String?,
      className: classData is Map ? classData['name'] as String? : null,
      section: classData is Map ? classData['section'] as String? : null,
      rollNumber: json['roll_number'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'] as String)
          : null,
      gender: json['gender'] as String?,
      guardianName: json['guardian_name'] as String?,
      guardianRelationship: json['guardian_relationship'] as String?,
      guardianPhone: json['guardian_phone'] as String?,
      guardianEmail: json['guardian_email'] as String?,
      addressStreet: json['address_street'] as String?,
      addressCity: json['address_city'] as String?,
      addressState: json['address_state'] as String?,
      addressZip: json['address_zip'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'class_id': classId,
      'roll_number': rollNumber,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
      'gender': gender,
      'guardian_name': guardianName,
      'guardian_relationship': guardianRelationship,
      'guardian_phone': guardianPhone,
      'guardian_email': guardianEmail,
      'address_street': addressStreet,
      'address_city': addressCity,
      'address_state': addressState,
      'address_zip': addressZip,
      'avatar_url': avatarUrl,
      'is_active': isActive,
    };
  }

  String get displayClass =>
      className != null ? '$className-${section ?? "A"}' : 'Unassigned';
}
