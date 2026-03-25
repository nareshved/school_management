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
      final userId = SupabaseService.currentUserId;
      if (userId == null) return;
      
      _classes = await SupabaseService.getTeacherClasses(userId);
      final classIds = _classes.map((e) => e['id'].toString()).toList();
      
      _students = await SupabaseService.getStudentsByClassIds(classIds);
    } catch (e) {
      debugPrint('Error loading students: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
