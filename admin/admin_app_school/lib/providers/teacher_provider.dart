import 'package:flutter/material.dart';
import '../../models/teacher_model.dart';
import '../../services/supabase_service.dart';

class TeacherProvider extends ChangeNotifier {
  List<TeacherModel> _teachers = [];
  List<Map<String, dynamic>> _subjects = [];
  bool _isLoading = true;

  List<TeacherModel> get teachers => _teachers;
  List<Map<String, dynamic>> get subjects => _subjects;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _subjects = await SupabaseService.getSubjects();
      _teachers = await SupabaseService.getTeachers();
    } catch (e) {
      // Log error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addOrUpdateTeacher(TeacherModel teacher) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (teacher.id != null) {
        await SupabaseService.updateTeacher(teacher.id!, teacher);
      } else {
        await SupabaseService.addTeacher(teacher);
      }
      await loadData(); 
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
