import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';

class TeacherDashboardProvider extends ChangeNotifier {
  int _assignedClasses = 0;
  int _activeHomeworks = 0;
  int _totalStudents = 0;
  List<Map<String, dynamic>> _todayClasses = [];
  String _subjectName = 'No Subject';
  bool _isLoading = true;

  int get assignedClasses => _assignedClasses;
  int get activeHomeworks => _activeHomeworks;
  int get totalStudents => _totalStudents;
  List<Map<String, dynamic>> get todayClasses => _todayClasses;
  String get subjectName => _subjectName;
  bool get isLoading => _isLoading;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final authId = SupabaseService.currentUserId;
      if (authId == null) return;

      final teacherProfile = await SupabaseService.getTeacherProfileByUserId(authId);
      if (teacherProfile == null) return;
      final teacherId = teacherProfile['id'].toString();
      _subjectName = teacherProfile['subjects']?['name'] ?? 'No Subject';

      final classesData = await SupabaseService.getTeacherClasses(teacherId);
      final classIds = classesData.map((e) => e['id']).toList();
      
      _assignedClasses = classesData.length;
      _todayClasses = classesData;

      if (classIds.isNotEmpty) {
        int totalHw = 0;
        int studentCount = 0;
        for (var cid in classIds) {
          final hws = await SupabaseService.getHomework(classId: cid.toString());
          totalHw += hws.length;
          final students = await Supabase.instance.client
              .from('students')
              .select('id')
              .eq('class_id', cid)
              .eq('is_active', true);
          studentCount += (students as List).length;
        }
        _activeHomeworks = totalHw;
        _totalStudents = studentCount;
      }
    } catch (e) {
      // Ignore
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
