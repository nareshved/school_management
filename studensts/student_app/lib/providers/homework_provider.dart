import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class HomeworkProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Map<String, dynamic>> _homeworks = [];

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get homeworks => _homeworks;

  Future<void> loadHomeworks(String classId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _homeworks = await SupabaseService.getHomework(classId: classId);
    } catch (e) {
      debugPrint('Error loading homeworks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
