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
      _classes = await SupabaseService.getClasses();
      _students = await SupabaseService.getStudents();
    } catch (e) {
      // Log error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addOrUpdateStudent(StudentModel student) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (student.id != null) {
        await SupabaseService.updateStudent(student.id!, student);
      } else {
        await SupabaseService.addStudent(student);
      }
      await loadData(); // Reload
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteStudent(String studentId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await SupabaseService.deleteStudent(studentId);
      await loadData();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
