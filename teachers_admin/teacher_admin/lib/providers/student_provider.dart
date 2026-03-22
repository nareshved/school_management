import 'package:flutter/material.dart';
import '../../models/student_model.dart';
import '../../services/supabase_service.dart';

class StudentProvider extends ChangeNotifier {
  List<StudentModel> _students = [];
  List<Map<String, dynamic>> _classes = [];
  bool _isLoading = true;

  List<StudentModel> get students => _students;
  List<Map<String, dynamic>> get classes => _classes;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final teacherId = SupabaseService.currentUserId;
      if (teacherId == null) return;
      _classes = await SupabaseService.getTeacherClasses(teacherId);
      final classIds = _classes.map((e) => e['id']).toList();
      
      final allStudents = await SupabaseService.getStudents();
      _students = allStudents.where((s) => classIds.contains(s.classId)).toList();
    } catch (e) {
      // Log error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
