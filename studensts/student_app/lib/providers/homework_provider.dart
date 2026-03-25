import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class HomeworkProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Map<String, dynamic>> _homeworks = [];
  final Set<String> _completedHomeworkIds = {};

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get homeworks => _homeworks;

  bool isCompleted(String homeworkId) => _completedHomeworkIds.contains(homeworkId);

  Future<void> loadHomeworks(String classId, {String? studentId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _homeworks = await SupabaseService.getHomework(classId: classId);
      
      if (studentId != null) {
        final submissions = await SupabaseService.getHomeworkSubmissions(studentId);
        _completedHomeworkIds.clear();
        for (var sub in submissions) {
          _completedHomeworkIds.add(sub['homework_id'].toString());
        }
      }
    } catch (e) {
      debugPrint('Error loading homeworks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsDone(String studentId, String homeworkId) async {
    try {
      await SupabaseService.markHomeworkAsDone(studentId, homeworkId);
      _completedHomeworkIds.add(homeworkId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking homework as done: $e');
      rethrow;
    }
  }
}
