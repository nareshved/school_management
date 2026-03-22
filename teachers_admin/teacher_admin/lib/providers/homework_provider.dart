import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class HomeworkProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _homeworkList = [];
  bool _isLoading = true;

  List<Map<String, dynamic>> get homeworkList => _homeworkList;
  bool get isLoading => _isLoading;

  Future<void> loadHomework(String classId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _homeworkList = await SupabaseService.getHomework(classId: classId);
    } catch (e) {
      // Ignore
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addHomework(String title, String description, String dueDate, String classId, String subjectId) async {
    try {
      final teacherId = SupabaseService.currentUserId;
      if (teacherId == null) throw Exception('No user logged in');
      
      await SupabaseService.addHomework({
        'title': title,
        'description': description,
        'due_date': dueDate,
        'class_id': classId,
        'subject_id': subjectId,
        'teacher_id': teacherId,
      });
      await loadHomework(classId);
    } catch (e) {
      rethrow;
    }
  }
}
