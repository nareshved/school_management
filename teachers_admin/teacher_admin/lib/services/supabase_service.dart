import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/student_model.dart';
import '../models/teacher_model.dart';
import '../models/fee_model.dart';
import '../models/notice_model.dart';

class SupabaseService {
  static SupabaseClient get _client => Supabase.instance.client;

  // ── Auth ──────────────────────────────────────────────
  static Future<UserModel?> signIn(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user != null) {
      return await getUserProfile(response.user!.id);
    }
    return null;
  }

  static Future<UserModel?> signUp(String email, String password, String fullName, String role) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
    
    if (response.user != null) {
      final user = UserModel(
        id: response.user!.id,
        email: email,
        fullName: fullName,
        role: role,
        createdAt: DateTime.now(),
      );
      await createUserProfile(user);
      
      try {
        if (role == 'student') {
          await _client.from('students').insert({
            'user_id': user.id,
            'full_name': user.fullName,
            'is_active': true,
          });
        } else if (role == 'teacher') {
          await _client.from('teachers').insert({
            'user_id': user.id,
            'full_name': user.fullName,
            'email': user.email,
            'is_active': true,
          });
        }
      } catch (e) {
        print('Error creating role-specific profile: $e');
      }

      return user;
    }
    return null;
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static User? get currentUser => _client.auth.currentUser;

  static String? get currentUserId => _client.auth.currentUser?.id;

  static Future<UserModel?> getUserProfile(String userId) async {
    final data =
        await _client.from('users').select().eq('id', userId).maybeSingle();
    if (data != null) {
      return UserModel.fromJson(data);
    }
    return null;
  }

  static Future<void> createUserProfile(UserModel user) async {
    await _client.from('users').upsert(user.toJson());
  }

  // ── Dashboard Stats ──────────────────────────────────
  static Future<Map<String, dynamic>> getDashboardStats() async {
    final studentsCount =
        await _client.from('students').select('id').count(CountOption.exact);
    final teachersCount =
        await _client.from('teachers').select('id').count(CountOption.exact);
    final feesData = await _client.from('fees').select('amount, status');

    double totalFees = 0;
    double collectedFees = 0;
    int pendingTasks = 0;

    for (final fee in feesData) {
      final amount = (fee['amount'] as num).toDouble();
      totalFees += amount;
      if (fee['status'] == 'paid') {
        collectedFees += amount;
      } else {
        pendingTasks++;
      }
    }

    return {
      'totalStudents': studentsCount.count,
      'totalTeachers': teachersCount.count,
      'totalFees': totalFees,
      'collectedFees': collectedFees,
      'pendingTasks': pendingTasks,
    };
  }

  // ── Classes ──────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getClasses() async {
    final data =
        await _client.from('classes').select().order('name').order('section');
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<Map<String, dynamic>?> getTeacherProfileByUserId(String userId) async {
    return await _client
        .from('teachers')
        .select('*, subjects(name)')
        .eq('user_id', userId)
        .maybeSingle();
  }

  static Future<List<Map<String, dynamic>>> getTeacherClasses(String userId) async {
    final teacher = await _client.from('teachers').select('id').eq('user_id', userId).maybeSingle();
    
    if (teacher == null) return [];
    
    final realTeacherId = teacher['id'].toString();
    
    final data = await _client
        .from('teacher_classes')
        .select('classes(*)')
        .eq('teacher_id', realTeacherId);
    return data.map<Map<String, dynamic>>((e) => e['classes'] as Map<String, dynamic>).toList();
  }

  // ── Subjects ──────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getSubjects() async {
    final data = await _client.from('subjects').select().order('name');
    return List<Map<String, dynamic>>.from(data);
  }

  // ── Students ──────────────────────────────────────────────
  static Future<List<StudentModel>> getStudents({String? classId}) async {
    var query = _client
        .from('students')
        .select('*, classes(name, section)')
        .eq('is_active', true)
        .order('full_name');

    if (classId != null) {
      query = _client
          .from('students')
          .select('*, classes(name, section)')
          .eq('is_active', true)
          .eq('class_id', classId)
          .order('full_name');
    }

    final data = await query;
    return data.map((json) => StudentModel.fromJson(json)).toList();
  }

  static Future<List<StudentModel>> getStudentsByClassIds(List<String> classIds) async {
    if (classIds.isEmpty) return [];
    final data = await _client
        .from('students')
        .select('*, classes(name, section)')
        .filter('class_id', 'in', classIds)
        .eq('is_active', true)
        .order('full_name');
    return (data as List).map((json) => StudentModel.fromJson(json)).toList();
  }

  static Future<StudentModel> getStudent(String id) async {
    final data = await _client
        .from('students')
        .select('*, classes(name, section)')
        .eq('id', id)
        .single();
    return StudentModel.fromJson(data);
  }

  static Future<void> addStudent(StudentModel student) async {
    await _client.from('students').insert(student.toJson());
    await _logActivity('Student Added', '${student.fullName} enrolled');
  }

  static Future<void> updateStudent(String id, StudentModel student) async {
    await _client.from('students').update(student.toJson()).eq('id', id);
  }

  static Future<void> deleteStudent(String id) async {
    await _client
        .from('students')
        .update({'is_active': false}).eq('id', id);
  }

  // ── Teachers ──────────────────────────────────────────────
  static Future<List<TeacherModel>> getTeachers() async {
    final data = await _client
        .from('teachers')
        .select('*, subjects(name), teacher_classes(classes(name, section))')
        .eq('is_active', true)
        .order('full_name');
    return data.map((json) => TeacherModel.fromJson(json)).toList();
  }

  static Future<void> addTeacher(TeacherModel teacher) async {
    await _client.from('teachers').insert(teacher.toJson());
    await _logActivity('Teacher Added', '${teacher.fullName} joined faculty');
  }

  static Future<void> updateTeacher(String id, TeacherModel teacher) async {
    await _client.from('teachers').update(teacher.toJson()).eq('id', id);
  }

  static Future<void> assignTeacherClass(
      String teacherId, String classId) async {
    await _client.from('teacher_classes').upsert({
      'teacher_id': teacherId,
      'class_id': classId,
    });
  }

  // ── Fees ──────────────────────────────────────────────
  static Future<List<FeeModel>> getFees({String? status}) async {
    var query = _client
        .from('fees')
        .select('*, students(full_name, roll_number, classes(name, section))')
        .order('created_at', ascending: false);

    if (status != null) {
      query = _client
          .from('fees')
          .select('*, students(full_name, roll_number, classes(name, section))')
          .eq('status', status)
          .order('created_at', ascending: false);
    }

    final data = await query;
    return data.map((json) => FeeModel.fromJson(json)).toList();
  }

  static Future<void> addFee(FeeModel fee) async {
    await _client.from('fees').insert(fee.toJson());
  }

  static Future<void> markFeePaid(String feeId) async {
    await _client.from('fees').update({
      'status': 'paid',
      'paid_date': DateTime.now().toIso8601String().split('T').first,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', feeId);
    await _logActivity('Fee Payment', 'Fee payment recorded');
  }

  // ── Attendance ──────────────────────────────────────────────
  static Future<void> markAttendance(
      List<Map<String, dynamic>> records) async {
    await _client.from('attendance').upsert(records);
    await _logActivity('Attendance Marked', 'Attendance submitted');
  }

  static Future<List<Map<String, dynamic>>> getAttendance({
    String? studentId,
    String? classId,
    String? date,
  }) async {
    var query = _client.from('attendance').select('*, students(full_name, roll_number)');

    if (studentId != null) {
      query = query.eq('student_id', studentId);
    }
    if (classId != null) {
      query = query.eq('class_id', classId);
    }
    if (date != null) {
      query = query.eq('date', date);
    }

    final data = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  // ── Notices ──────────────────────────────────────────────
  static Future<List<NoticeModel>> getNotices({List<String>? classIds, String? teacherId}) async {
    var query = _client.from('notices').select('*, users(full_name)');
    
    if (classIds != null && classIds.isNotEmpty || teacherId != null) {
      final filters = <String>[];
      if (classIds != null && classIds.isNotEmpty) {
        filters.add('target_class_id.in.(${classIds.join(",")})');
        filters.add('target_type.eq.all');
      }
      if (teacherId != null) {
        filters.add('created_by.eq.$teacherId');
      }
      
      if (filters.isNotEmpty) {
        query = query.or(filters.join(','));
      }
    }

    final data = await query.order('created_at', ascending: false);
    return (data as List).map((json) => NoticeModel.fromJson(json)).toList();
  }

  static Future<void> addNotice(NoticeModel notice) async {
    await _client.from('notices').insert(notice.toJson());
    await _logActivity('Notice Sent', notice.title);
  }

  // ── Homework ──────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getHomework(
      {String? classId}) async {
    var query = _client.from('homework').select(
        '*, subjects(name), classes(name, section), teachers(full_name)');

    if (classId != null) {
      query = query.eq('class_id', classId);
    }

    final data = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<void> addHomework(Map<String, dynamic> homework) async {
    await _client.from('homework').insert(homework);
  }

  static Future<void> updateHomework(String id, Map<String, dynamic> homework) async {
    await _client.from('homework').update(homework).eq('id', id);
  }

  static Future<void> deleteHomework(String id) async {
    await _client.from('homework').delete().eq('id', id);
  }

  // ── Activity Log ──────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getRecentActivities(
      {int limit = 10}) async {
    final data = await _client
        .from('activity_log')
        .select('*, users(full_name)')
        .order('created_at', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<void> _logActivity(String action, String description) async {
    try {
      if (currentUserId != null) {
        await _client.from('activity_log').insert({
          'action': action,
          'description': description,
          'created_by': currentUserId,
        });
      }
    } catch (_) {
      // Silent fail for activity logging
    }
  }
}
