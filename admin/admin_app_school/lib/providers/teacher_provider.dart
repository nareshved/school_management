import 'package:flutter/material.dart';
import '../../models/teacher_model.dart';
import '../../services/supabase_service.dart';

class TeacherProvider extends ChangeNotifier {
  List<TeacherModel> _teachers = [];
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _classes = [];
  bool _isLoading = true;

  List<TeacherModel> get teachers => _teachers;
  List<Map<String, dynamic>> get subjects => _subjects;
  List<Map<String, dynamic>> get classes => _classes;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _subjects = await SupabaseService.getSubjects();
      _classes = await SupabaseService.getClasses();
      _teachers = await SupabaseService.getTeachers();
    } catch (e) {
      // ignore
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addOrUpdateTeacher(
    TeacherModel teacher,
    List<String> selectedClassIds,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      String teacherId;
      if (teacher.id != null) {
        await SupabaseService.updateTeacher(teacher.id!, teacher);
        teacherId = teacher.id!;
      } else {
        final inserted = await SupabaseService.addTeacherReturning(teacher);
        teacherId = inserted;
      }

      // Remove all existing class assignments then re-assign in bulk
      await SupabaseService.clearTeacherClasses(teacherId);
      if (selectedClassIds.isNotEmpty) {
        await SupabaseService.assignTeacherClassesBulk(teacherId, selectedClassIds);
      }

      await loadData();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTeacher(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await SupabaseService.deleteTeacher(id);
      await loadData();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
