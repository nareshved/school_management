class FeeModel {
  final String? id;
  final String studentId;
  final String? studentName;
  final String? studentClass;
  final String? studentRoll;
  final double amount;
  final String feeType;
  final String status;
  final DateTime? dueDate;
  final DateTime? paidDate;
  final String? academicYear;
  final DateTime? createdAt;

  FeeModel({
    this.id,
    required this.studentId,
    this.studentName,
    this.studentClass,
    this.studentRoll,
    required this.amount,
    this.feeType = 'Tuition',
    this.status = 'pending',
    this.dueDate,
    this.paidDate,
    this.academicYear,
    this.createdAt,
  });

  factory FeeModel.fromJson(Map<String, dynamic> json) {
    final studentData = json['students'];
    String? studentClass;
    if (studentData is Map && studentData['classes'] is Map) {
      final cls = studentData['classes'];
      studentClass = '${cls['name']}-${cls['section']}';
    }
    return FeeModel(
      id: json['id'] as String?,
      studentId: json['student_id'] as String,
      studentName: studentData is Map ? studentData['full_name'] as String? : null,
      studentClass: studentClass,
      studentRoll: studentData is Map ? studentData['roll_number'] as String? : null,
      amount: (json['amount'] as num).toDouble(),
      feeType: json['fee_type'] as String? ?? 'Tuition',
      status: json['status'] as String? ?? 'pending',
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'] as String)
          : null,
      paidDate: json['paid_date'] != null
          ? DateTime.tryParse(json['paid_date'] as String)
          : null,
      academicYear: json['academic_year'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'amount': amount,
      'fee_type': feeType,
      'status': status,
      'due_date': dueDate?.toIso8601String().split('T').first,
      'paid_date': paidDate?.toIso8601String().split('T').first,
      'academic_year': academicYear,
    };
  }

  bool get isPaid => status == 'paid';
  bool get isPending => status == 'pending';
  bool get isOverdue => status == 'overdue';

  String get initials {
    if (studentName == null) return '??';
    final parts = studentName!.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return studentName!.substring(0, 2).toUpperCase();
  }
}
